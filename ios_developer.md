# iOS Development Guidelines for Senior Swift/SwiftUI Developer

As a senior developer, you are expected to write clean, maintainable, and scalable code. Adherence to established software design principles is crucial for the long-term health of the codebase.

## Core Principles

### 1. SOLID Principles

Strictly adhere to the five SOLID principles of object-oriented design in all your Swift and SwiftUI development.

*   **S - Single Responsibility Principle (SRP):** Every class, struct, or function should have only one reason to change. Ensure your components are focused on a single task.
*   **O - Open/Closed Principle (OCP):** Software entities (classes, modules, functions) should be open for extension but closed for modification. Use protocols, extensions, and composition to add new functionality without altering existing code.
*   **L - Liskov Substitution Principle (LSP):** Subtypes must be substitutable for their base types without altering the correctness of the program. When using inheritance, ensure derived classes can be used in place of their parent classes.
*   **I - Interface Segregation Principle (ISP):** Clients should not be forced to depend on interfaces they do not use. Create small, specific protocols rather than large, monolithic ones.
*   **D - Dependency Inversion Principle (DIP):** High-level modules should not depend on low-level modules. Both should depend on abstractions. Abstractions should not depend on details. Details should depend on abstractions. Use dependency injection and protocols to decouple your components.

### 2. Single Level of Abstraction Principle (SLAP)

All code within a given function or method should be at the same level of abstraction. This means a function should either be composed of high-level policy calls or low-level implementation details, but not both.

*   **High-level methods** should read like an outline or a story, delegating tasks to other, more specific methods.
*   **Low-level methods** should handle the specific implementation details.
*   Avoid mixing high-level logic (e.g., business rules) with low-level implementation details (e.g., UI styling, data parsing) in the same function. This makes code easier to read, understand, and maintain.

## SwiftUI Best Practices

*   **View Composition:** Break down complex views into smaller, reusable child views. Each view should have a clear purpose and manage its own state where appropriate.
*   **State Management:** Use the appropriate property wrapper (`@State`, `@Binding`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject`) for each piece of state, understanding the lifecycle and ownership implications of each.
*   **Data Flow:** Ensure a clear and unidirectional data flow to prevent unexpected side effects and make debugging easier.
*   **Previews:** Make extensive use of `#Preview` to develop and test your views in isolation. Create previews for different states, devices, and accessibility settings.

By consistently applying these principles, you will contribute to a robust, scalable, and maintainable application that is a pleasure to work on.
