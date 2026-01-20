#!/usr/bin/env python3
"""
Taskwarrior hook for tour project management.

Project structure: tour.[name_of_tour].[venue].[category]
- Requires at least one sub-part (tour alone is rejected)

Auto-tagging:
- +work, +tour always added for tour projects
- +name_of_tour (prioritized if both name and venue exist)
- +tour.[category] when category is present (standalone or in full path)

Tag removal:
- When project changes or is removed, tour-related tags are updated
- +work is preserved (may be used for non-tour work tasks)

Configuration:
- Categories are read from ~/.task/tour-categories.txt (one per line)
- If file doesn't exist, falls back to built-in defaults

Install:
    cp on-add-tour.py ~/.task/hooks/
    ln -s ~/.task/hooks/on-add-tour.py ~/.task/hooks/on-modify-tour.py
    chmod +x ~/.task/hooks/on-add-tour.py
"""

import sys
import json
import os

# =============================================================================
# Configuration
# =============================================================================

CONFIG_FILE = os.path.expanduser("~/.task/tour-categories.txt")

# Fallback if config file doesn't exist
DEFAULT_CATEGORIES = {
    "logistics",
    "advance",
}


def load_categories() -> set:
    """
    Load categories from config file.
    File format: one category per line, blank lines and # comments ignored.
    """
    if not os.path.exists(CONFIG_FILE):
        return DEFAULT_CATEGORIES

    categories = set()
    try:
        with open(CONFIG_FILE, "r") as f:
            for line in f:
                line = line.strip()
                # Skip empty lines and comments
                if line and not line.startswith("#"):
                    categories.add(line.lower())
        return categories if categories else DEFAULT_CATEGORIES
    except Exception:
        return DEFAULT_CATEGORIES


# =============================================================================
# Helper Functions
# =============================================================================


def get_project_parts(project: str) -> list:
    """Split project string into parts."""
    if not project:
        return []
    return project.split(".")


def get_tour_tags(project: str, categories: set) -> tuple[set, set]:
    """
    Determine which tags should be added for a tour project.

    Returns:
        (all_tags, removable_tags)
        - all_tags: complete set of tags to add
        - removable_tags: tags that should be removed if project changes
          (excludes +work since that may be wanted independently)
    """
    parts = get_project_parts(project)

    if not parts or parts[0] != "tour":
        return set(), set()

    all_tags = {"work", "tour"}
    removable_tags = {"tour"}  # +work is NOT auto-removed

    if len(parts) < 2:
        # Just "tour" - no specific tags to add
        return all_tags, removable_tags

    second_part = parts[1]

    # Check if this is a standalone category (tour.[category])
    if second_part in categories and len(parts) == 2:
        tag = f"tour.{second_part}"
        all_tags.add(tag)
        removable_tags.add(tag)
    else:
        # Has a tour name - add it as a tag
        all_tags.add(second_part)
        removable_tags.add(second_part)

        # Check for category in the path (last part if 3+ parts)
        # tour.name.venue.category or tour.name.category
        if len(parts) >= 3:
            last_part = parts[-1]
            if last_part in categories:
                category_tag = f"tour.{last_part}"
                all_tags.add(category_tag)
                removable_tags.add(category_tag)

    return all_tags, removable_tags


# =============================================================================
# Main Processing
# =============================================================================


def process_task(
    task: dict, original_task: dict | None = None, categories: set | None = None
) -> tuple[dict, str | None, bool]:
    """
    Process task and return (modified_task, feedback_message, should_reject).
    """
    if categories is None:
        categories = load_categories()

    tags = set(task.get("tags", []))
    project = task.get("project", "")
    project_parts = get_project_parts(project)
    feedback = []

    # Track original values for on-modify
    original_project = original_task.get("project", "") if original_task else ""

    # -------------------------------------------------------------------------
    # Reject bare "tour" project
    # -------------------------------------------------------------------------
    if project == "tour":
        return (
            task,
            "⚠️  Project 'tour' requires at least one sub-level.\n"
            "   Please include at least one of the following: Tour Name, Venue, Task Category\n\n"
            "   Examples:\n"
            "     project:tour.tmck                      (tour name)\n"
            "     project:tour.logistics                 (standalone category)\n"
            "     project:tour.tmck.the_pageant          (tour + venue)\n"
            "     project:tour.tmck.the_pageant.advance  (tour + venue + category)",
            True,  # Reject
        )

    # -------------------------------------------------------------------------
    # Handle project changes (on-modify) - remove old tags first
    # -------------------------------------------------------------------------
    project_changed = original_task is not None and original_project != project

    if project_changed and original_project:
        _, old_removable = get_tour_tags(original_project, categories)
        removed = []
        for tag in old_removable:
            if tag in tags:
                tags.discard(tag)
                removed.append(f"-{tag}")
        if removed:
            feedback.append(f"Removed: {', '.join(removed)}")

    # -------------------------------------------------------------------------
    # Add tags for tour project
    # -------------------------------------------------------------------------
    if project_parts and project_parts[0] == "tour" and len(project_parts) > 1:
        new_tags, _ = get_tour_tags(project, categories)
        added = []
        for tag in new_tags:
            if tag not in tags:
                tags.add(tag)
                added.append(f"+{tag}")
        if added:
            feedback.append(f"Added: {', '.join(sorted(added))}")

    # -------------------------------------------------------------------------
    # Warn if +work tag without tour project (don't reject)
    # -------------------------------------------------------------------------
    has_tour_project = (
        project_parts and project_parts[0] == "tour" and len(project_parts) > 1
    )

    if "work" in tags and not has_tour_project:
        feedback.append(
            "💡 If this task is related to a tour/show, make sure to add it to a tour project"
        )

    # -------------------------------------------------------------------------
    # Update task with modified tags
    # -------------------------------------------------------------------------
    task["tags"] = sorted(list(tags))

    # Build feedback message
    feedback_msg = None
    if feedback:
        feedback_msg = "[tour hook] " + " | ".join(feedback)

    return (task, feedback_msg, False)


def main():
    # Load categories once at startup
    categories = load_categories()

    lines = sys.stdin.readlines()

    if len(lines) == 1:
        # on-add event
        task = json.loads(lines[0])
        original_task = None
    elif len(lines) >= 2:
        # on-modify event
        original_task = json.loads(lines[0])
        task = json.loads(lines[1])
    else:
        sys.exit(0)

    modified_task, feedback, should_reject = process_task(
        task, original_task, categories
    )

    if should_reject:
        print(feedback, file=sys.stderr)
        sys.exit(1)

    print(json.dumps(modified_task))

    if feedback:
        print(feedback, file=sys.stderr)

    sys.exit(0)


if __name__ == "__main__":
    main()
