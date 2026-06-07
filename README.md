# Project E — Clean Architecture

[Project A-Z](#project-a-z) 의 E 단계.

단계마다 새로운 기술 스택을 하나씩 더해가며, 조금씩 다른 기능을 구현해 나갑니다.
E 단계는 **기능을 D(async/await 항공편 조회)와 동일하게 두고**, 구조만 **Clean Architecture**로 재구성한 **순수 리팩터링**입니다 —
코드를 **Domain / Data / Presentation** 계층으로 나누고 **의존성을 역전**시켜, ViewModel이 네트워킹·저장소 구현을 몰라도 되게 만듭니다.

## 다루는 기술

- UIKit (Programmatic, Storyboard 없음)
- MVVM
- Diffable Data Source
- Combine (상태 바인딩)
- async/await (`URLSession`/`Codable` 실제 API 호출)
- **Clean Architecture** (계층 분리 · 의존성 역전 · Use Case · DI 컨테이너) ← 이번 단계 추가분

## 기능 (D와 동일)

1. **내 일정 목록** — 생성된 일정을 보여줍니다. `+` 로 추가를, 왼쪽으로 밀어 **삭제**합니다.
2. **편명·날짜 입력** — **편도/왕복**을 고르고 편명(예: `KE705`)과 날짜를 넣어 `조회`하면 **실제 API를 비동기 호출**합니다.
3. **일정 자동 생성** — 조회된 항공편(도착 도시·날짜·시각·항공사)으로 일정을 만들어 목록에 저장합니다.
4. **읽기 전용 달력** — 일정을 탭하면 기간을 표시하는 달력으로 이동합니다(왕복은 범위 표시).

## 왜 Clean Architecture인가

D에서는 ViewModel이 `AeroDataBoxReservationService`·`TripStore`를 **직접** 들고 호출했습니다 — 프레임워크·데이터 출처에 강결합되어, 테스트하거나 데이터 소스를 갈아끼우기 어렵습니다.

E는 의존성을 뒤집습니다. ViewModel은 **Use Case**에만, Use Case는 **Repository 프로토콜(Domain)** 에만 의존합니다. 실제 API 호출(`URLSession`)이나 인메모리 저장(`@Published`)은 **Data 계층의 구현 세부사항**일 뿐이라, Domain·Presentation은 그 존재를 모릅니다. 다음 단계 F(XCTest)에서 Repository를 Mock으로 갈아끼워 테스트하는 것으로 이어집니다.

### 의존성 규칙

```
Presentation  ──▶  Domain  ◀──  Data
  (ViewModel)      (UseCase)     (Repository 구현)
                 (Repository
                   프로토콜)
```

가장 안쪽 **Domain은 아무것도 모릅니다**(UIKit·네트워킹 import 0). 바깥(Presentation·Data)이 안쪽(Domain)을 향해 의존합니다. Data가 Domain의 Repository 프로토콜을 **구현**(의존성 역전)하고, 모든 조립은 컴포지션 루트(`AppDIContainer`)에서 한 번에 이뤄집니다.

## 구조

```
project-e-clean-architecture/
├── Config.xcconfig                  # base config — RAPIDAPI_KEY 를 Info.plist 로 주입
├── Secrets.local.xcconfig           # 실제 키 (gitignore — 직접 생성)
├── Info.plist                       # RapidAPIKey = $(RAPIDAPI_KEY)
└── ProjectE/
    ├── App/                         # 컴포지션 루트
    │   ├── AppDelegate.swift
    │   ├── SceneDelegate.swift      # 컨테이너로 루트(내 일정) 생성
    │   └── AppDIContainer.swift     # Repository → UseCase → ViewModel/VC 조립
    ├── Domain/                      # 순수 Swift (UIKit·네트워킹 의존 0)
    │   ├── Entity/
    │   │   ├── Trip.swift           # 일정 = 가는 편 + (옵션)오는 편, 도메인 로직만
    │   │   ├── FlightLeg.swift      # 항공편 1편(구간)
    │   │   └── Destination.swift    # 여행지 (이름 + 나라)
    │   ├── Repository/              # 프로토콜 (구현은 Data)
    │   │   ├── ReservationRepository.swift   # fetchFlight(_:date:) async throws
    │   │   └── TripRepository.swift          # add/remove + tripsPublisher
    │   └── UseCase/
    │       ├── CreateTripUseCase.swift       # 조회 → 일정 생성·저장
    │       ├── ObserveTripsUseCase.swift     # 일정 스트림 구독
    │       └── DeleteTripUseCase.swift       # 일정 삭제
    ├── Data/                        # Domain 프로토콜의 구현
    │   ├── Reservation/
    │   │   └── AeroDataBoxReservationRepository.swift  # URLSession+Codable+DTO 매핑
    │   ├── Trip/
    │   │   └── InMemoryTripRepository.swift   # @Published 인메모리 저장소
    │   └── Config/
    │       └── AppConfig.swift               # Info.plist 에서 RapidAPIKey 읽기
    └── Presentation/                # View + ViewModel (Use Case에만 의존)
        ├── Common/
        │   ├── TripFormatter.swift           # 도메인 → 화면 문자열 (표시 전용)
        │   └── UIControl+Publisher.swift     # UIControl 이벤트 → Combine
        ├── TripList/                # 내 일정 목록 (루트)
        │   ├── TripListViewModel.swift        # ObserveTrips/DeleteTrip 의존
        │   └── TripListViewController.swift   # 다음 화면은 컨테이너가 주입
        ├── AddReservation/         # 편명·날짜 입력 + 비동기 조회
        │   ├── AddReservationViewModel.swift  # CreateTripUseCase 의존
        │   └── AddReservationViewController.swift
        └── TripCalendar/           # 읽기 전용 달력
            ├── TripCalendarViewModel.swift
            ├── TripCalendarViewController.swift
            ├── CalendarDay.swift
            └── CalendarDayCell.swift
```

## D 단계와 달라진 점 (구조만)

| | D (async/await) | E (+ Clean Architecture) |
|---|---|---|
| 기능 | 편명·날짜 → 조회 → 일정 | **동일** |
| ViewModel 의존 | `Service`·`Store` 직접 호출 | **Use Case만** |
| 데이터 출처 | ViewModel이 앎 | **Repository 프로토콜 뒤로 숨김** |
| 표시 문자열 | 엔티티(`Trip`)가 가짐 | **`TripFormatter`(Presentation)로 이동** |
| 조립 | `SceneDelegate`가 직접 | **`AppDIContainer`(컴포지션 루트)** |

핵심 아이디어: `AddReservationViewModel`은 `CreateTripUseCase`만 호출할 뿐, 그 안에서 `AeroDataBoxReservationRepository`가 실제 API를 치는지 / Mock이 샘플을 돌려주는지 모릅니다. 교체·테스트 시 **Repository 프로토콜의 구현만** 갈아끼우면 됩니다.

## API 키 설정

실제 데이터는 **[AeroDataBox](https://rapidapi.com/aedbx-aedbx/api/aerodatabox)**(RapidAPI, HTTPS, 무료 티어)를 씁니다. **키는 빌드 구성(xcconfig)으로 주입**하고 커밋되지 않습니다.

레포 루트에 `Secrets.local.xcconfig`(`.gitignore` 대상)를 만들고 키를 넣으세요:

```
RAPIDAPI_KEY = your_rapidapi_key
```

주입 흐름: `Secrets.local.xcconfig` → `Config.xcconfig`(base configuration, `#include?`) → `Info.plist`의 `RapidAPIKey`(`$(RAPIDAPI_KEY)`) → 런타임 `AppConfig.rapidAPIKey`.

> 키 파일이 없어도 빌드·실행은 됩니다(`#include?`). 키가 비어 있으면 조회 시 "RapidAPI 키가 없어요" 에러가 표시됩니다.

## 빌드

Xcode 16+ / iOS 16.0+ / Swift 5.0. 외부 의존성 없음(시스템 `URLSession`만 사용).

```
open ProjectE.xcodeproj
```

## Project A-Z

단계마다 새로운 기술 스택을 하나씩 더해가며, 조금씩 다른 기능을 구현해 나가는 iOS 학습 프로젝트입니다.

| | 추가 스택 |
|---|---|
| A | UIKit + MVVM |
| B | Diffable Data Source |
| C | Combine |
| D | async/await |
| **E** | **Clean Architecture** |
| F | XCTest |
| G | SwiftUI |
| H | Supabase |
| I | FCM |
| J | CoreData |
| K | Tuist |
| L | SPM 모듈화 |
| M | SwiftData |
| N | Objective-C + libexif |
| O | Swift Testing |
| P | UI Test |
| Q | CI/CD (GitHub Actions) |

각 단계는 별도 레포로 관리합니다.
