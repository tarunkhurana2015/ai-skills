# 05 - Data Models & API Contracts Specification

## 1. Domain Entities & Data Models

### Entity: [Entity Name, e.g. UserProfile]
- **Location**: `packages/[feature_name]_feature/lib/domain/[entity_name].dart`
- **Fields**:
  ```dart
  class UserProfile {
    final String id;
    final String email;
    final String displayName;
    final DateTime createdAt;
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

## 3. Serialization Strategy
- Models must provide explicit `fromJson(Map<String, dynamic> json)` and `toJson()` methods.
- Type casting must include safe fallbacks:
  ```dart
  id: json['id'] as String? ?? '',
  createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
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
