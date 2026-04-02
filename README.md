# 4ThePlot

4ThePlot is a software engineering project focused on event discovery, event hosting, platform moderation, and growth tracking.

## Project Overview

This repository contains requirement artifacts for 4ThePlot.
The current domain model has three roles:

1. Goer/Participant
2. Business
3. Admin

Both Goer and Business users can organize events.

## Role Summary

| Role | Main Goal |
| :--- | :--- |
| Goer/Participant | Discover events, join events, and host personal events. |
| Business | Promote branded events, run campaigns, and host professional events. |
| Admin | Moderate platform activity, verify trusted hosts, and monitor platform health. |

## Core Functional Scope

### Goer/Participant

- Personalized category following
- Organizer review and trust signals
- Waitlist support for full events
- In-app map navigation
- Friend invitations
- Event hosting tools (drafts, capacity, broadcast, recurring setup, analytics)

### Business

- Sponsored discovery placement
- Branded profile management
- Lead generation tools
- Partner co-hosting support
- ROI and conversion tracking
- Event hosting tools (drafts, capacity, broadcast, recurring setup, analytics)

### Admin

- Reported content processing
- Verification badge assignment
- Global platform announcements
- Dispute resolution with chat evidence
- Daily growth and activity monitoring

## Repository Structure

| Path | Description |
| :--- | :--- |
| README.md | Main project overview and documentation index. |
| Requirments.txt | Requirement-writing guide, scenario/use-case definitions, and requirement categories. |
| User Stories/user_stories.md | Full user stories grouped by role with IDs (GO, BIZ, ADM). |
| User Scenarios/user_scenarios_list.md | Short user scenario list in table format mapped to role-based IDs. |
| User Scenarios/User Scenarios.docx | Document version of scenario artifacts. |
| Designs/Design Mock Up.pdf | Initial design mockup reference. |

## Requirement Artifact Definitions

### User Scenario

Describes context and motivation, and explains what the user wants to do.

### Use Case

Describes how the system satisfies the user goal, including normal flow and possible exceptions.

### Functional Requirements

Define the services and behaviors the system must provide.

### Non-Functional Requirements

Define constraints such as performance, standards, process constraints, and quality attributes.

## Traceability Convention

- Story IDs: GO-xx, BIZ-xx, ADM-xx
- Scenario IDs: GO-xx, BIZ-xx, ADM-xx

This shared ID pattern keeps user stories and user scenarios aligned for later use-case expansion.

## Current Status

- User stories are updated to the merged-role model (no standalone Organizer role).
- User scenarios are updated and table-structured based on the latest stories.
- Supporting design and requirement notes are included in this repository.

