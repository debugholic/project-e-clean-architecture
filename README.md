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
- **Clean Architecture** ← 이번 단계 추가분
  - 계층 분리(Domain / Data / Presentation)와 의존성 역전
  - 추상/구현 분리 — `Interface/` 와 `Implementation/`, `...Impl` 네이밍
  - `UseCase<Request, Response>` — 모든 UseCase가 같은 시그니처
  - ViewModel `Input`/`Output`/`Actions`
  - `AppFlowCoordinator` — 화면 전환을 한곳에
  - 네트워크 계층 분리 — `NetworkService` / `Requestable` / DTO / Mapper
  - `AppDIContainer` — 컴포지션 루트

## 기능 (D와 동일)

1. **내 일정 목록** — 생성된 일정을 보여줍니다. `+` 로 추가를, 왼쪽으로 밀어 **삭제**합니다.
2. **편명·날짜 입력** — **편도/왕복**을 고르고 편명(예: `KE705`)과 날짜를 넣어 `조회`하면 **실제 API를 비동기 호출**합니다.
3. **일정 자동 생성** — 조회된 항공편(도착 도시·날짜·시각·항공사)으로 일정을 만들어 목록에 저장합니다.
4. **읽기 전용 달력** — 일정을 탭하면 기간을 표시하는 달력으로 이동합니다(왕복은 범위 표시).

## 의존성 규칙

```
Presentation  ──▶  Domain  ◀──  Data
  (ViewModel)      (UseCase)     (Repository 구현)
                 (Repository
                   프로토콜)
```

가장 안쪽 **Domain은 아무것도 모릅니다**(UIKit·네트워킹 import 0). 바깥(Presentation·Data)이 안쪽(Domain)을 향해 의존합니다. Data가 Domain의 Repository 프로토콜을 **구현**(의존성 역전)하고, 모든 조립은 컴포지션 루트(`AppDIContainer`)에서 한 번에 이뤄집니다.

역전은 Repository 경계에서만 일어나지 않습니다. **UseCase도 프로토콜(`Interface/`)과 구현(`Implementation/`)으로 나뉘어** ViewModel은 `any CreateTripUseCase` 같은 추상에만 의존합니다. 구현체를 아는 파일은 컴포지션 루트 하나뿐입니다.

## 구조

```
project-e-clean-architecture/
├── Config.xcconfig                  # base config — RAPIDAPI_KEY 를 Info.plist 로 주입
├── Secrets.local.xcconfig           # 실제 키 (gitignore — 직접 생성)
├── Info.plist                       # RapidAPIKey = $(RAPIDAPI_KEY)
└── ProjectE/
    ├── App/                         # 컴포지션 루트 + 화면 흐름
    │   ├── AppDelegate.swift
    │   ├── SceneDelegate.swift
    │   ├── AppDIContainer.swift     # 조립만 — 전환은 모름
    │   └── Flow/
    │       └── AppFlowCoordinator.swift   # push/pop 이 여기에만 있다
    ├── Domain/                      # 순수 Swift (UIKit·네트워킹 의존 0)
    │   ├── Entity/
    │   │   ├── Trip.swift           # 가는 편 + (옵션)오는 편
    │   │   ├── FlightLeg.swift      # departure / arrival: Movement
    │   │   ├── Movement.swift       # 공항 + 예정 시각
    │   │   ├── Airport.swift        # 도시 · IATA · 국가
    │   │   └── ScheduledTime.swift
    │   ├── Interface/               # 추상
    │   │   ├── Repository/
    │   │   │   ├── TripRepository.swift
    │   │   │   └── ReservationRepository.swift
    │   │   └── UseCase/
    │   │       ├── UseCase.swift            # execute(request:) 공통 계약
    │   │       ├── CreateTripUseCase.swift  # + CreateTripRequest
    │   │       ├── DeleteTripUseCase.swift
    │   │       └── ObserveTripsUseCase.swift
    │   └── Implementation/UseCase/  # 구현 (...Impl)
    ├── Data/                        # Domain 프로토콜의 구현
    │   ├── Config/AppConfig.swift   # Info.plist 에서 RapidAPIKey 읽기
    │   ├── DTO/DataTransferObject.swift     # toDomain() 공통 계약
    │   ├── Network/
    │   │   ├── Interface/           # NetworkService · Requestable · NetworkConfigurable
    │   │   │                        # NetworkSessionManager · HTTPMethod · NetworkError
    │   │   └── Implementation/      # ...Impl + APIConfig(범용 설정)
    │   ├── Reservation/
    │   │   ├── AeroDataBoxReservationRepositoryImpl.swift
    │   │   ├── Endpoint/            # 요청 경로·헤더
    │   │   ├── DTO/                 # 응답 모양만 (연산 멤버 0)
    │   │   └── Mapper/              # DTO → Domain 변환
    │   └── Trip/
    │       ├── TripRepositoryImpl.swift
    │       └── Storage/             # TripStorage ← 저장 메커니즘 분리
    │           ├── Interface/
    │           └── Implementation/  # InMemoryTripStorageImpl
    └── Presentation/
        ├── View/                    # ViewController + Cell (전환 안 함)
        ├── ViewModel/               # ViewModel + Input/Output/Actions
        ├── Model/CalendarDay.swift
        └── Util/                    # TripFormatter · UIControl+Publisher
```

## API 키 설정

실제 데이터는 **[AeroDataBox](https://rapidapi.com/aedbx-aedbx/api/aerodatabox)**(RapidAPI, HTTPS, 무료 티어)를 씁니다. **키는 빌드 구성(xcconfig)으로 주입**하고 커밋되지 않습니다.

레포 루트에 `Secrets.local.xcconfig`(`.gitignore` 대상)를 만들고 키를 넣으세요:

```
RAPIDAPI_KEY = your_rapidapi_key
```

주입 흐름: `Secrets.local.xcconfig` → `Config.xcconfig`(base configuration, `#include?`) → `Info.plist`의 `RapidAPIKey`(`$(RAPIDAPI_KEY)`) → 런타임 `AppConfig.rapidAPIKey`.

> 키 파일이 없어도 빌드·실행은 됩니다(`#include?`). 키가 비었거나 잘못되면 서버가 401/403을 돌려주고, Repository가 이를 `ReservationError.missingAPIKey` 로 옮겨 "RapidAPI 키가 없어요" 로 표시됩니다.

## 빌드

Xcode 16+ / iOS 16.0+ / Swift 5.0. 외부 의존성 없음(시스템 `URLSession`만 사용).

```
open ProjectE.xcodeproj
```

## Project A-Z

실무에서 다뤄온 기술을 단계별로 정리하는 프로젝트입니다.

| | 추가 스택 |
|---|---|
| A | UIKit + MVVM |
| B | Diffable Data Source |
| C | Combine |
| D | async/await |
| **E** | **Clean Architecture** |
| F | XCTest |
| G | SwiftUI |
| H | SPM 모듈화 |
| I | Micro Feature Architecture |
| J | Tuist |
| K | Core Data |
| L | CloudKit |
| M | APNs |
| N | SwiftData |
| O | Objective-C + libexif |
| P | Swift Testing |
| Q | UI Test |
| R | CI/CD (GitHub Actions) |

각 단계는 별도 레포로 관리합니다.
