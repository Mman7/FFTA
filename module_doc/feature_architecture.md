# Feature Architecture — Expenses

This project uses a **Feature-first + Layered Architecture**.

Each feature is separated into its own folder.
For example, the `expenses` feature contains everything related to expenses.

## 📁 Folder Structure

```text
features/
└── expenses/
    ├── data/
    │   ├── expense_repository.dart
    │   └── expense_repository_impl.dart
    │
    ├── models/
    │   └── expense.dart
    │
    └── presentation/
        ├── cubit/
        │   ├── expense_cubit.dart
        │   └── expense_state.dart
        │
        ├── pages/
        │   ├── expenses_page.dart
        │   ├── add_expense_page.dart
        │   └── expense_detail_page.dart
        │
        └── widgets/
            ├── expense_card.dart
            └── category_bottom_sheet.dart
```

---

## 🧱 Layers

### 1. Models

```text
models/
└── expense.dart
```

Defines what an `Expense` looks like.

Example:

```dart
class Expense {
  final String id;
  final int amount;
  final String category;
  final String note;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
  });
}
```

The model should only represent data.

It should **not**:

* Call Firebase
* Call an API
* Manage UI state
* Navigate between pages

---

### 2. Data

```text
data/
├── expense_repository.dart
└── expense_repository_impl.dart
```

Responsible for data access.

#### `expense_repository.dart`

Defines the repository contract.

```dart
abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);

  Future<List<Expense>> getExpenses(String roomId);
}
```

It defines **what operations are available**, but not how they are implemented.

#### `expense_repository_impl.dart`

Contains the actual implementation.

```dart
class ExpenseRepositoryImpl implements ExpenseRepository {

  @override
  Future<void> addExpense(Expense expense) async {
    // Firebase / API
  }

  @override
  Future<List<Expense>> getExpenses(String roomId) async {
    // Firebase / API
  }
}
```

`ExpenseRepositoryImpl` decides **how the data is retrieved or stored**.

For example:

```text
ExpenseRepositoryImpl
        ↓
   Firebase
```

or:

```text
ExpenseRepositoryImpl
        ↓
      Dio
        ↓
   REST API
```

The Cubit does not need to know which implementation is being used.

---

### 3. Presentation

```text
presentation/
├── cubit/
├── pages/
└── widgets/
```

Contains everything related to the UI.

---

## Cubit

```text
cubit/
├── expense_cubit.dart
└── expense_state.dart
```

### `expense_state.dart`

Describes the current state of the UI.

Example:

```dart
sealed class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;

  ExpenseLoaded(this.expenses);
}

class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError(this.message);
}
```

State answers:

> **"What should the UI display right now?"**

---

### `expense_cubit.dart`

Handles user actions and application flow.

Example:

```dart
class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository repository;

  ExpenseCubit(this.repository)
      : super(ExpenseInitial());

  Future<void> loadExpenses(String roomId) async {
    emit(ExpenseLoading());

    try {
      final expenses =
          await repository.getExpenses(roomId);

      emit(ExpenseLoaded(expenses));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
```

Cubit is responsible for:

* Receiving actions from the UI
* Calling the Repository
* Managing application state
* Emitting new states

Cubit should **not directly access Firebase or HTTP**.

---

## Pages

```text
pages/
├── expenses_page.dart
├── add_expense_page.dart
└── expense_detail_page.dart
```

Pages represent complete screens.

### `expenses_page.dart`

Displays the expense list.

```text
ExpensesPage
├── Total spending
├── Filters
├── Expense list
└── Add button
```

### `add_expense_page.dart`

Handles the Add Expense screen.

```text
AddExpensePage
├── Amount
├── Category
├── Note
├── Date
└── Add button
```

### `expense_detail_page.dart`

Displays and manages a single expense.

```text
ExpenseDetailPage
├── Amount
├── Category
├── Note
├── Paid by
├── Edit
└── Delete
```

Pages should communicate with the Cubit instead of directly accessing Firebase.

---

## Widgets

```text
widgets/
├── expense_card.dart
└── category_bottom_sheet.dart
```

Reusable UI components for the Expenses feature.

### `expense_card.dart`

Displays one expense.

```dart
ExpenseCard(
  expense: expense,
)
```

### `category_bottom_sheet.dart`

Displays the category selection UI.

```text
Food
Transport
Shopping
Entertainment
Health
Travel
Others
```

Widgets should focus on **UI**, not data access.

---

# 🔄 Data Flow

The main flow of the feature is:

```text
User
 ↓
Page / Widget
 ↓
ExpenseCubit
 ↓
ExpenseRepository
 ↓
ExpenseRepositoryImpl
 ↓
Firebase / API
```

When data is returned:

```text
Firebase / API
 ↓
ExpenseRepositoryImpl
 ↓
ExpenseRepository
 ↓
ExpenseCubit
 ↓
ExpenseState
 ↓
Page / Widget
```

---

# 🧠 Responsibilities

| Layer             | Responsibility                    |
| ----------------- | --------------------------------- |
| `models`          | Define data                       |
| `repository`      | Define data operations            |
| `repository_impl` | Implement data operations         |
| `cubit`           | Handle application flow and state |
| `state`           | Describe current UI state         |
| `pages`           | Build complete screens            |
| `widgets`         | Build reusable UI components      |

---

# 🚫 Dependency Rules

Avoid this:

```text
Page
 ↓
Firebase
```

Avoid this:

```text
Cubit
 ↓
Firebase
```

Prefer:

```text
Page
 ↓
Cubit
 ↓
Repository
 ↓
RepositoryImpl
 ↓
Firebase / API
```

The UI should not care how data is stored.

The Cubit should not care whether the data comes from Firebase or a REST API.

The Repository defines the contract, while the Repository Implementation handles the actual data source.

---

# 🎯 Core Principle

Keep each layer focused on one responsibility.

```text
Model
"What does the data look like?"

Repository
"What can I do with the data?"

RepositoryImpl
"How do I actually do it?"

Cubit
"What should the application do?"

State
"What is the current state?"

Page / Widget
"What should the user see?"
```

This keeps the feature **simple, testable, and easy to change** without introducing unnecessary architecture.
