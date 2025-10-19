# 🧩 SwiftUI DDHList - Drag and Drop Hierarchical LIst

**SwiftUI DDHList** is a simple **SwiftUI UI component** example that demonstrates how to build a **list view** supporting:

- 🖱️ **Drag & Drop** reordering  
- 🧱 **Hierarchical structures** with nested sections  
- 🗑️ **Swipe-to-delete** interactions  
- 📱 A clean **SwiftUI Tab Bar** to switch between examples  

---

## 💡 About

This repository is **UI-only** — it focuses on the **visual and interactive behavior** of a draggable list.  
The component provides all the necessary information about **where an item has been dropped** (e.g., between which indices or relative to which element).  

However, the **actual logic for reordering the data model** (e.g., updating your array or hierarchy) is **delegated to the user** of this component.  
In other words, you decide how the list’s data should change after a drag-and-drop event.

---

## 🧭 Included Examples

1. **`DragDropListExampleView`** — a simple list with drag & drop and swipe-to-delete  
2. **`HierarchicalDragDropListExampleView`** — a hierarchical (multi-level) list supporting nested drag & drop  

---

## 🧱 Use Case

This project is meant as a **reusable UI component** or a **playground** for experimenting with list interactions in SwiftUI projects.

---

## 🛠️ Built With

- SwiftUI  
- Xcode  
- Swift 5.5+
- iOS 16.4+

---

Created by **Alberto Bruno**
