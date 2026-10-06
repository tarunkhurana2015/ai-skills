# 05 - Data Models & API Contracts Specification

## 1. Domain Entities & Data Models

### Entity: [Entity Name, e.g. UserProfile]
- **Location**: `packages/[feature_name]_feature/lib/domain/[entity_name].dart`
- **Fields & Freezed Definition**:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';

  part '[entity_name].freezed.dart';
  part '[entity_name].g.dart';

  @freezed
  class [EntityName] with _$[EntityName] {
    const factory [EntityName]({
      required String id,
      required String email,
      required String displayName,
      required DateTime createdAt,
    }) = _[EntityName];

    factory [EntityName].fromJson(Map<String, dynamic> json) =>
        _$[EntityName]FromJson(json);
  }
  ```

---

## 2. API Endpoints & Request / Response Schemas

### Endpoint 1: `GET /api/v1/[resource]`
- **Description**: [What this endpoint retrieves]
- **Query Parameters**:
  - `page`: `int` (default: `1`)
  - `limit`: `int` (default: `20`)
- **Headers**:
  - `Authorization`: `Bearer <token>`
  - `Accept`: `application/json`

#### 200 OK Response Payload:
```json
{
  "status": "success",
  "data": [
    {
      "id": "item_123",
      "name": "Sample Item",
      "is_active": true,
      "created_at": "2026-10-01T12:00:00Z"
    }
  ],
  "meta": {
    "total": 1,
    "page": 1,
    "limit": 20
  }
}
```

#### Error Contract (4xx / 5xx):
```json
{
  "status": "error",
  "code": "RESOURCE_NOT_FOUND",
  "message": "The requested item could not be found."
}
```

---

## 3. Freezed Serialization & Code Generation Strategy
- All domain models and business entities must be defined using **Freezed** (`@freezed`) to ensure:
  - **Compile-time Immutability**: Domain models are immutable value objects.
  - **Structural Equality**: Auto-generated `==` operator and `hashCode` overrides.
  - **Copying**: Auto-generated `copyWith` methods for safe updates.
  - **Type-safe JSON**: Seamless integration with `json_serializable` for `fromJson` and `toJson`.
  - **Pattern Matching**: Sealed union support when modeling variant domain states.

### Required Dependencies (`pubspec.yaml`):
```yaml
dependencies:
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.15
  freezed: ^2.5.8
  json_serializable: ^6.9.4
```

### Code Generation Workflow:
Execute the code generator to produce `*.freezed.dart` and `*.g.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Repository Interface Contract
Repositories define clear abstract contracts in `lib/domain/` to decouple presentation logic from network implementations:

```dart
abstract interface class ItemRepository {
  Future<List<Item>> getItems({int page = 1, int limit = 20});
  Future<Item> getItemById(String id);
  Future<Item> createItem(ItemDraft draft);
  Future<void> deleteItem(String id);
}
```
