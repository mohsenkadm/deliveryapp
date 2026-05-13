# DeliverySystem — Modified API routes, parameters, and AI handoff

This document lists **HTTP routes (backlinks)** that were added or materially changed for the **mobile app and related backend** workstream, with **query/body parameters**, **auth**, and **response shape**. Use the **prompt at the end** when asking an AI to adjust clients or server code.

**Base URL (example):** `https://{host}`  
**Auth:** `Authorization: Bearer {jwt}` unless marked *public*.

**Standard JSON envelope** (`ApiResponse<T>`):

```json
{
  "success": true,
  "messageAr": "…",
  "messageEn": "…",
  "data": { }
}
```

Always validate `success` before using `data`.

---

## 1. Settings (company profile for any authenticated user)

| Method | Path | Auth | Query | Body | Notes |
|--------|------|------|-------|------|--------|
| GET | `/api/settings/company` | Any authenticated role | — | — | Returns `SystemSettingsDto` (logo, company name, etc.). **New** endpoint for mobile. |
| GET | `/api/settings` | `Admin` only | — | — | Same payload as company; admin tooling. |
| PUT | `/api/settings` | `Admin` only | — | `SystemSettingsDto` | Updates settings. |

---

## 2. Customer mobile (`/api/mobile/customer`)

| Method | Path | Auth | Query | Body | Notes |
|--------|------|------|-------|------|--------|
| POST | `/api/mobile/customer/orders` | `Customer` | — | `CreateInvoiceDto` | **Server overrides:** `customerId` = JWT subject, `employeeId` = `null`, `invoiceSource` = `Customer` (0). Client may send `customerId: 0`; it is ignored. |
| GET | `/api/mobile/customer/orders/{id}/invoice` | `Customer` | — | — | HTML invoice; QR is **inline PNG (data URI)** via QRCoder, not external QR host. |

Other customer routes (`GET products`, `GET orders`, etc.) follow existing `MobileCustomerController`; product query still accepts `search`, `categoryId`, `branchId`, `nearExpiryDays`, `page`, `pageSize`.

**`CreateInvoiceDto` (body highlights):** `customerId`, `employeeId`, `invoiceSource`, `promoCode`, `branchId`, `deliveryScheduleType`, `scheduledDeliveryDate`, `details[]` with `productId`, `quantity`, `unitPrice`, `discount`.

---

## 3. Representative mobile (`/api/mobile/rep`)

| Method | Path | Auth | Query | Body | Notes |
|--------|------|------|-------|------|--------|
| GET | `/api/mobile/rep/invoices` | `Representative`, `Employee` | `status` (optional `InvoiceStatus`) | — | Uses **`ForRepresentativeId`** = rep from JWT: invoices where `SalesRepresentativeId`, `EmployeeId`, or `Customer.EmployeeId` matches rep (covers post–driver-assign). |
| GET | `/api/mobile/rep/invoices/{id}` | same | — | — | **404** if invoice outside rep scope (sales rep, employee, or customer’s `employeeId`). |
| POST | `/api/mobile/rep/invoices` | same | — | `CreateInvoiceDto` | **Overrides:** `employeeId` = JWT rep id, `invoiceSource` = `Representative` (1). Wholesale rep: server validates stock on **main warehouses** only. |
| GET | `/api/mobile/rep/products/main-warehouses` | same | `search`, `categoryId`, `warehouseId`, `nearExpiryDays` | — | Products with stock in **non–sub-warehouses**; optional filter to one main `warehouseId`. |
| GET | `/api/mobile/rep/warehouses/main` | same | — | — | List of main warehouses (`id`, `name`, `branchId`). |
| GET | `/api/mobile/rep/warehouse` | same | — | — | Sub-warehouse inventory; each item includes **`wholesalePrice`**, **`retailPrice`**, **`discountPercentage`** plus `quantity`, `productId`, `productName`. |
| POST | `/api/mobile/rep/transfer-orders` | same | — | `CreateTransferOrderDto` | `orderType` forced to outbound to rep. **Individual rep:** server resolves **main** source warehouse and **rep sub-warehouse** from DB when applicable. |
| POST | `/api/mobile/rep/transfer-orders/return` | same | — | `CreateTransferOrderDto` | Uses **`CreateReturnTransferOrderCommand`** (return workflow / statuses). Individual rep: **from/to** warehouses resolved from DB when applicable. |

**`CreateTransferOrderDto`:** `fromWarehouseId`, `toWarehouseId`, `orderType` (often overwritten by controller), `notes`, `details[]` → `productId`, `requestedQuantity`.

---

## 4. Driver mobile (`/api/mobile/driver`)

| Method | Path | Auth | Query | Body | Notes |
|--------|------|------|-------|------|--------|
| GET | `/api/mobile/driver/orders` | `Driver`, `Employee` | `status` (optional) | — | When `status` omitted, only **active pipeline** rows: `WarehouseProcessing`, `AwaitingDelivery`, `Delivered`, `Completed`. Response includes **amounts** (`totalAmount`, `paidAmount`, `remainingAmount`, payment status). |
| GET | `/api/mobile/driver/orders/{id}` | same | — | — | `DriverOrderDetailDto`: customer, items with **unitPrice**, **discount**, **lineTotal**, invoice totals and payment status. |
| POST | `/api/mobile/driver/orders/{id}/pickup` | same | — | — | **New:** `WarehouseProcessing` → `AwaitingDelivery` if assigned driver matches JWT. |
| POST | `/api/mobile/driver/orders/{id}/deliver` | same | — | — | Requires current status **`AwaitingDelivery`** → `Delivered`. |
| POST | `/api/mobile/driver/orders/{id}/collect` | same | — | `DriverCollectPaymentDto` | Optional cash collection: `recordPayment` (bool, default `true`), `amount`, `notes`. If `recordPayment && amount > 0`, records `CustomerToDriver` and updates invoice paid amount. |
| PATCH | `/api/mobile/driver/orders/{id}/status` | same | — | `UpdateInvoiceStatusDto` | Allowed targets: `Delivered`, `Completed`, `Rejected`; special path to `Delivered` from `AwaitingDelivery` uses deliver command. |

**`DriverCollectPaymentDto`:** `recordPayment`, `amount`, `notes`.

---

## 5. Supervisor & manager mobile (invoice listing change)

| Method | Path | Auth | Query | Notes |
|--------|------|------|-------|--------|
| GET | `/api/mobile/supervisor/reps/{repId}/invoices` | `Supervisor` + rep under supervisor | `status` | Uses `GetAllInvoicesQuery(ForRepresentativeId: repId, …)` instead of `EmployeeId` only. |
| GET | `/api/mobile/manager/reps/{repId}/invoices` | `SalesManager`, `Manager`, … | `status` | Same `ForRepresentativeId` behavior. |

---

## 6. Control panel (MVC) — invoice workflow (for internal tools)

Relative paths (same site as ControlPanel):

| Action | Typical URL | Method | Notes |
|--------|-------------|--------|--------|
| Invoice list | `/Invoices` | GET | Filters; warehouse keeper sees subset of statuses. |
| Invoice details | `/Invoices/Details/{id}` | GET | QR via **local** `InvoiceQrCodeHelper` (`ViewBag.QrDataUri`). Driver list filtered to **Driver** role. `ShowDriverDispatchForm` controls dispatch UI vs “awaiting driver pickup”. |
| Accept invoice | `/Invoices/Accept` | POST | Uses **`ApproveInvoiceCommand`**: `ApprovedByEmployeeId` is **null** for Admin session, else session employee id (must exist in `Employees` table). |
| Dispatch | `/Invoices/DispatchDriver` | POST | `id`, `employeeId` — assigns driver, keeps **`WarehouseProcessing`** until driver confirms pickup in app. |

Forms use anti-forgery token where applicable.

---

## 7. Data model fields clients should know

- **`InvoiceDto`:** may include `salesRepresentativeId`, `salesRepresentativeName` (rep who cut the invoice before driver assignment).
- **Driver assignment:** `employeeId` on invoice often becomes **driver** after dispatch; use sales rep fields for “who sold”.
- **`InvoiceStatus`:** includes `WarehouseProcessing`, `AwaitingDelivery`, `Delivered`, etc. (see `DeliverySystem.Domain.Enums.InvoiceStatus`).

---

## 8. Prompt to paste into an AI (for app or API follow-up)

Copy everything inside the block below into your AI session when you want coordinated changes (mobile + API):

```text
You are working on the DeliverySystem .NET solution (ASP.NET Core API + MVC ControlPanel).

Context:
- All mobile JSON APIs return ApiResponse<T> with success, messageAr, messageEn, data.
- JWT: Authorization: Bearer {token}. NameIdentifier claim holds user id (customer id OR employee id depending on role).

Representative API base path: /api/mobile/rep
- GET invoices uses scope ForRepresentativeId (not only EmployeeId) so invoices remain visible after a driver is assigned.
- GET /products/main-warehouses?search=&categoryId=&warehouseId=&nearExpiryDays= — main warehouses only (IsSubWarehouse=false).
- GET /warehouses/main — list main warehouses.
- POST /invoices overwrites employeeId and invoiceSource from token.
- GET /warehouse returns RepWarehouseDto; each RepWarehouseItemDto includes wholesalePrice, retailPrice, discountPercentage, quantity, productId, productName.
- Transfer POST /transfer-orders and POST /transfer-orders/return: for Individual representative with a sub-warehouse, the server may override from/to warehouse IDs from the database; client-supplied IDs may be ignored or validated.

Customer API: /api/mobile/customer
- POST /orders overwrites customerId, sets employeeId null, invoiceSource Customer.

Driver API: /api/mobile/driver
- GET /orders returns financial fields on list items when unfiltered; filters to active statuses when status query omitted.
- POST /orders/{id}/pickup — driver confirms pickup from warehouse (WarehouseProcessing → AwaitingDelivery).
- POST /orders/{id}/collect — optional body DriverCollectPaymentDto { recordPayment, amount, notes } for CustomerToDriver payment.

Settings:
- GET /api/settings/company — any authenticated user for app branding/settings.

ControlPanel Invoices:
- Accept uses ApproveInvoiceCommand with nullable approver employee id for Admin.
- Dispatch assigns driver but order may stay WarehouseProcessing until driver pickup in mobile app.

Constraints:
- Prefer minimal, focused diffs; keep MediatR handlers in Application layer; controllers delegate only.
- Do not break ApiResponse contract.
- SQL Server: avoid multiple cascade paths from Invoices to Employees; SalesRepresentativeId FK uses Restrict/NoAction.

Task (fill in):
[Describe your change, e.g. “Add field X to GET /api/mobile/rep/warehouse items and update Flutter models.”]
```

---

## 9. File pointers (where logic lives)

| Area | Primary files |
|------|----------------|
| Rep queries / DTOs | `src/Application/Features/Representatives/Queries/RepresentativeMobileQueries.cs`, `RepresentativeMainWarehouseProductQueries.cs` |
| Invoices | `src/Application/Features/Invoices/Commands/InvoiceCommands.cs`, `InvoiceWorkflowCommands.cs` |
| Transfers | `src/Application/Features/TransferOrders/Commands/TransferOrderCommands.cs` |
| Driver DTOs/queries | `src/Application/Features/Drivers/Queries/DriverMobileQueries.cs` |
| API controllers | `src/API/Controllers/Mobile*.cs`, `SettingsController.cs` |
| QR helpers | `src/API/Helpers/InvoiceQrCodeHelper.cs`, `src/ControlPanel/Helpers/InvoiceQrCodeHelper.cs` |
| Panel invoices | `src/ControlPanel/Controllers/InvoicesController.cs`, `Views/Invoices/Details.cshtml` |

---

*Generated for handoff to humans and AI assistants. Update this file when you add or change routes.*
