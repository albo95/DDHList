# 🧩 SwiftUI DDHList

**SwiftUI DDHList** is a lightweight and flexible SwiftUI component designed to showcase advanced list behaviors such as:

- 🖱️ **Drag & Drop** reordering  
- 🧱 **Hierarchical structures** with nested children  
- 🗑️ **Swipe-to-delete** interactions  
- 📱 **Tabbed example interface** to explore all modes  
- 💡 Built 100% in **SwiftUI**, no UIKit bridging

---

## 📖 Overview

This package provides two main list components:

| Component | Description |
|------------|-------------|
| `DDListView` | A **flat list** supporting drag & drop between items and swipe-to-delete |
| `DDHListView` | A **hierarchical list** that supports nested items with expand/collapse and reordering at multiple levels |

Both components are **UI-only** — they manage the drag & drop visuals, feedback, and gesture states, but **you control how your data updates** when an item is dropped or deleted.

This design gives you full flexibility to define how items are structured or moved inside your own model.

---

## ⚙️ Features

### 🖱️ Drag & Drop
- Drag and drop any list item
- Detect precise drop targets:
  - Between items (separator)
  - On another item (make it a child or replace it)
- Visual hover feedback with configurable `hoverColor`

### 🧱 Hierarchical Support
- Expandable and collapsible sections
- Support for nested children (via your `ItemType`’s `children` property)
- Works recursively at any level

### 🗑️ Swipe to Delete
- Customizable delete button (`deleteView`)
- Smooth spring animation
- Optional enable/disable with `isDeletionEnabled`

### 🧭 Drop Context Awareness
The component provides context for every drop event:
```swift
onItemDroppedOnSeparator: { dragged, above, below in ... }
onItemDroppedOnOtherItem: { dragged, target in ... }

## 🧱 Use Case

This project is meant as a **reusable UI component** or a **playground** for experimenting with list interactions in SwiftUI projects.  
- Compatible with **iOS 16.4+**

---

## 🛠️ Built With

- SwiftUI  
- Xcode  
- Swift 5.5+

---

Created by **Alberto Bruno**
