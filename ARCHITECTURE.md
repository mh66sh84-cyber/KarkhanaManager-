# Architecture and agreed scope

Step 1 supplies a Flutter setup screen, light/dark/system themes, Firebase initialization,
a tenant path helper, conservative Firestore rules, and platform generation instructions.
It does not implement authentication screens, profile writes, ledgers, PDF, or backup yet.
The app title is a product name, not a factory name. There are no invented business details.

## Tenant model for subsequent steps
One Firebase owner UID owns one business. Multiple businesses may have the same display name.
A renamed business keeps the same UID and data. No staff/shared-account permissions yet.

Planned document paths:
- businesses/{ownerUid}: businessName, ownerName, verified phone, timestamps
- businesses/{ownerUid}/workers/{workerId}
- businesses/{ownerUid}/workers/{workerId}/entries/{entryId}
- businesses/{ownerUid}/lots/{lotId}

Worker entries will be typed work, sample, advance, or payment. A daily advance must be
counted once, not both inside work and again as a payment. Store money in integer minor
units, and represent fabric meters with fixed precision. A negative balance represents
worker credit/overpayment; never silently clamp it to zero. Persist source entries and
calculate balances, rather than trusting editable totals.

Rules are the server-side security boundary. TenantStore alone is not security.
Step 1 denies all writes. Each later module must add field validation and tenant-specific
permissions, with emulator tests for anonymous access, owner access, and cross-owner denial.
No wildcard public access, business-name IDs, or client-editable ownership.

## Authentication decisions
Use phone + OTP initially. Firebase built-in password auth is email/password, not
phone/password. Do not store passwords in Firestore or use invented email addresses.
If password access is later needed, link a verified email/password provider or design a
separate reviewed authentication backend. Phone changes require verified phone credential
updates on the SAME Firebase UID; changing profile text is insufficient.

## Offline and account switching
Firestore mobile persistence is enabled by default. Offline use applies to cached records;
first sign-in and initial server fetch require connectivity. Cached financial data remains
on the device. In Step 2, tear down every tenant listener and clear in-memory state before
showing a different account. Plan a pending-write-aware cache-clearing flow for shared
phones; never discard unsynced writes silently or reuse a previous user's profile stream.

## Later module details
Business name comes from the authenticated profile for headers, PDFs, and WhatsApp.
Planned exports contain a schema version and tenant identity. Restore must validate all
records and reject mismatched business ownership by default. Never trust paths from JSON.
Delivery overdue means not delivered and due date is before the business-local today.
Lot-received and payment-received stamps are record indicators, not cryptographic signatures.
Theme selection currently lasts only for the app session; persistence comes later.
