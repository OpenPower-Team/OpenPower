# Game Design Document: OpenPower

## 1. Introduction

OpenPower is an open-source project aiming to recreate and expand upon the core mechanics of the game Superpower 2. The project prioritizes functionality, performance, and community modding, while maintaining a respectful approach to the original game's developers.

## 2. Game Overview

OpenPower is a geopolitical strategy game where players manage countries and interact with the world on a strategic level. The game world is represented by a map divided into regions, each with a unique color identifier and belonging to a specific country. Players can interact with these regions and countries through a world editor and, presumably, other gameplay mechanics yet to be explored.

## 3. World Structure

### 3.1. Regions

The game world is divided into regions, each defined by a unique color on a map image. This color serves as the primary key (`ID_COLOR`) in the game's database. Each region has the following attributes:

*   **ID_COLOR:** A unique hexadecimal color code (e.g., "#FF0000" for red).
*   **REGION_NAME:** The name of the region (e.g., "North America").
    *   **STRING_ID:** Text
    *   **OWNER_PLTC_ID:** The ID of the country that owns the region.
*   **OWNER_MIL_ID:** Text (3,3)
    *    **H_CLAIM_ID:** Text (3,3)
    *   **POP_15:** Integer
    *   **POP_15-65:** Integer
    *   **POP_65:** Integer

### 3.2. Countries

Countries are entities that own regions. Each country has the following attributes:

*   **ID:** A unique identifier for the country (e.g., "USA").
*   **FLAG:** Text

### 3.3. Data Storage

Region and country data is stored in an SQLite database located at `data/data.sqlite3`. The database contains two tables:

*   **REGION:** Stores information about regions (ID_COLOR, REGION_NAME, STRING_ID, OWNER_PLTC_ID, OWNER_MIL_ID, H_CLAIM_ID, POP_15, POP_15-65, POP_65).
*   **COUNTRY:** Stores information about countries (ID, FLAG).

## 4. World Editor

The World Editor is a tool accessible from the main menu that allows players to modify the game world's structure. It provides the following functionalities:

*   **Region Selection:** Players can click on the map image to select a region. The color of the clicked pixel determines the selected region.
*   **Region Information Display:** The editor displays the selected region's color code, name, and owner country. If the region is not found in the database, it displays "New Region".
*   **Region Editing:** Players can modify the region's name and owner country. The editor includes a dropdown to select the owner country.
*   **Data Persistence:** Changes made in the World Editor are saved to the SQLite database. The editor also initializes the database and creates the `REGION` and `COUNTRY` tables if they do not exist. **Note:** The table creation SQL statements in `WorldEditor.gd` are outdated and should be updated to match the current schema.

## 5. Main Menu

The main menu will provide access to the following options:

*   **World Editor:** Opens the World Editor.
*   **New Game:** (Planned) Starts a new game.
*   **Load Game:** (Planned) Loads a previously saved game.
*   **Options:** Opens the Options menu (audio, input, video settings).
*   **Exit:** Exits the game.

## 6. Roadmap - First Iteration

This section outlines the features planned for the first development iteration of the game. This iteration focuses on establishing the core mechanics and infrastructure necessary for future development and expansion.

*   **Main Menu and Settings:** Stabilize the main menu and settings.
*   **Saves:** Implement save game functionality.
*   **Basic AI:** Develop a basic AI for computer-controlled countries.
*   **Basic Player Country Management:**
    *   **Stability:** Implement a stability mechanic.
    *   **Expected Stability:** Implement an expected stability mechanic.
    *   **Population:** Track population statistics.
    *   **Population Aging:** Model population aging.
    *   **Population Growth:** Model population growth.
    *   **Army:** Track army personnel.
    *   **Region Conquest:** Implement region conquest mechanics.
    *   **Region Annexation:** Implement region annexation mechanics.

These features will include both UI and logic components.

## 7. Technology Stack

The project utilizes the following technologies:

*   **Game Engine:** Godot Engine
*   **Scripting Language:** GDScript
*   **Database:** SQLite

## 8. Future Development

Further sections will detail other game mechanics, UI elements, and gameplay features as they are explored.
