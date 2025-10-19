# 🧩 SwiftUI DDHList – Drag and Drop Hierarchical List

**SwiftUI DDHList** is a simple **SwiftUI UI component** example that demonstrates how to build a **list view** supporting:

- 🖱️ **Drag & Drop** reordering  
- 🧱 **Hierarchical structures** with nested sections  
- 🗑️ **Swipe-to-delete** interactions  
- 📱 A clean **SwiftUI Tab Bar** to switch between examples  

---

## 💡 About

This repository is **UI-only** — it focuses on the **visual and interactive behavior** of a draggable list.  
The component provides all the necessary information about **where an item has been dropped** (e.g., between which indices or relative to which element).  

However, the **actual logic for updating the data model** (e.g., modifying your array or hierarchy) is **delegated to the user** of this component.  
In other words, you decide how the list’s data should change after a drag-and-drop event.

---

## 🧭 Hierarchical Drag & Drop Behavior

In the **hierarchical version**, drag and drop allows flexible reordering:
- 🔹 Move an element **between items** on the same level  
- 🔹 Drop an element **as a child** of another item  
- 🔹 Drop an element **between existing children** of a parent item  

This makes it easy to build and manage complex nested lists where items can become parents or children dynamically.

---

## 🧩 Included Examples

1. **`DragDropListExampleView`** — a simple list with drag & drop and swipe-to-delete  
2. **`HierarchicalDragDropListExampleView`** — a hierarchical (multi-level) list supporting nested drag & drop  

---

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
