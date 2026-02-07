# PRD: AuctionStream Pro

## 1. Project Overview
**Objective:** A high-performance, real-time virtual auction application.
**Core Goal:** Demonstrate mastery of Agora RTC/RTM, Atomic State Synchronization, and Clean Architecture.
**Target Audience:** Recruiters looking for Senior Mobile Developers (Flutter/Native).

---

## 2. Technical Stack and Architecture

### 2.1 The Stack
**Framework:** Flutter (target SDK 3.x)
**State Management:** flutter_riverpod (specifically using AsyncNotifier for asynchronous state).
**Real-time Video and Audio:** agora_rtc_engine
**Signaling and Messaging:** agora_rtm
**Source of Truth:** firebase_database (Realtime Database for under 200ms sync).
**Dependency Injection:** Riverpod Providers (Ref-based injection).

### 2.2 Clean Architecture Folders
The AI agent should follow this directory structure:

lib/
├── core/                # App-wide constants, themes, error handling
├── features/
│   ├── auction/         # Logic for the live stream and bidding
│   │   ├── services/    # Repositories and Data Sources (Firebase/Agora)
│   │   ├── model/       # Entities and Use Cases
│   │   └── views/       # Widgets
│   └── lobby/           # Room entry logic
└── main.dart

---

## 3. Core Feature Specifications

### F1: The Dual-Role Engine
**Host Role:** Can publish video and audio. Receives Request to Speak signals.
**Audience Role:** Subscribes to the host stream. Can Bid or Request Stage Access.
**Logic:** Use ClientRoleType.clientRoleBroadcaster for Host and ClientRoleType.clientRoleAudience for listeners.

### F2: Atomic Bidding (The Senior Highlight)
**The Problem:** Preventing Race Conditions where two people bid the same amount simultaneously.
**The Fix:**
1. Do not use onValue listeners to update bids locally before confirming with the server.
2. Use Firebase Transactions.
3. Logic: transactionResult = await databaseRef.runTransaction(...). If the new bid is not greater than current_bid, reject the update.
**Visuals:** Successful transactions trigger an AgoraRTM broadcast to all peers to show a New High Bid animation.

### F3: Permission Queue (Signaling)
**Request Flow:** Audience sends an RTM Peer Message to the Host.
**Host Action:** Host UI shows a notification badge. Host can Approve or Reject.
**Promotion:** On approval, the specific User ID receives a Permissions Granted signal and programmatically upgrades their RTC role to Broadcaster to join the stage.

---

## 4. Screen Definitions (The MVP Scope)

### Page 1: Room Lobby (Route: /lobby)
Simple input for Username and Room ID.
Toggle for Join as Host (for testing purposes).
Goal: Initialize Agora and Firebase services via a Provider.

### Page 2: Live Auction Stage (Route: /auction_room)
**Video Layer:** Full-screen AgoraVideoView.
**Overlay Layer:**
1. Real-time Highest Bid ticker (Top).
2. Scrolling RTM Chat (Bottom Left).
3. Bid +$10 button (Bottom Right).
4. Request to Speak button (Bottom Center).
**Logic:** Must handle PopScope to ensure users leave the Agora channel properly on exit.

### Page 3: Host Moderation Panel (Route: /host_controls)
Note: Can be a BottomSheet or a separate Route.
List of users currently requesting stage access.
Buttons: Approve, Dismiss, Mute All.

---

## 5. Non-Functional Requirements (The Senior Quality)
**Connection Resilience:** Implement a ConnectionState provider. If Agora status becomes ConnectionChangedReason.interrupted, show a non-blocking Reconnecting toast.
**Memory Management:** Strictly enforce engine.release() and rtmClient.release() in the dispose method of the relevant Provider or StatefulWidget to prevent memory leaks.
**UI Performance:** Use RepaintBoundary for the video widget so that text-overlay updates don't trigger expensive video re-renders.

---

## 6. Implementation Instructions for the AI Agent
**Phase 1:** Setup the project structure and add dependencies: agora_rtc_engine, agora_rtm, firebase_core, firebase_database, flutter_riverpod, riverpod_annotation if not exist in pubspec.yaml
**Phase 2:** Implement the AuctionRepository using Firebase Transactions for the bidding logic.
**Phase 3:** Create the AgoraServiceProvider to handle RTC and RTM initialization.
**Phase 4:** Build the UI screens using existing base view in /lib/cores/base/base_provider_view.dart