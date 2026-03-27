<p align="middle">
  <img width="350px" src="docs/HubSpot-Logo1.png"/>
</p>
<h3 align="middle">HubSpot-Salesforce Sync Interface: OAuth 2.0 & Staging-Based Data Pipeline</h3>

<br/>

## 📝 작품소개

HubSpot과 Salesforce 간 데이터를 안정적으로 연동하기 위한 **API 기반 인터페이스 구축 프로젝트**입니다.

단순 데이터 조회 수준이 아닌 **인증 → 수집 → 가공 → 반영 → 조회**까지 이어지는 전체 데이터 흐름을 설계하고 구현하였습니다.

초기에는 Access Token 기반 연동을 적용한 뒤, 이를 **OAuth 2.0 기반 구조로 고도화하여 보안성과 운영 안정성 개선**하였습니다.

또한, IF(Staging) Object와 Batch 구조를 도입하여 **대량 데이터 처리와 데이터 무결성을 고려한 인터페이스 아키텍처**를 구현하였습니다.

<br/>

## 🌁 프로젝트 배경

### 외부 CRM 연동의 필요성

기업 환경에서는 하나의 솔루션만 사용하는 경우보다  
**여러 솔루션(HubSpot, Salesforce, SAP 등)을 함께 사용하는 경우가 많음**

이때 고객/영업 데이터가 서로 다른 시스템에 분산되면서  
**데이터 불일치, 수동 관리, 운영 비효율 문제**가 발생  

---

### 🎯 프로젝트 목표 (TO-BE)

**1. 보안 표준 준수 (Security Hardening)**
- Public App 기반 OAuth 2.0 인증 및 Named Credential 적용으로 보안성 및 운영 편의성 확보

**2. 안정적인 데이터 파이프라인 (Data Integrity)**
- **IF Object(임시 적재) → Batch(가공) → Real Object(반영)** 3단계 구조로 데이터 유실 방지 및 대량 처리 안정성 확보

**3. 확장성 있는 UI/UX 및 공통 모듈화**
- LWC 기반의 인터랙티브 검색 UI와 타 화면에서도 재사용 가능한 **범용 엑셀 다운로드 모듈** 구축

<br/>

## ⭐ 주요 기능

### 1. OAuth 2.0 기반 인증 구조

- HubSpot Public App 기반 OAuth 2.0 연동
- Salesforce Auth Provider + Named Credential 구성
- Refresh Token 기반 자동 토큰 갱신 처리

👉 기존 Access Token 방식 대비 보안성과 유지보수성 개선

### 2. IF Object 기반 인터페이스 아키텍처

데이터 흐름:

```
HubSpot API → IF Object → Batch → Salesforce Object
```

- IF_Account, IF_MeetingLog__c에 원천 데이터 저장  
- Batch Apex로 데이터 가공 및 정제  
- Account, MeetingLog__c로 최종 반영  

👉 직접 반영을 피하고 중간 레이어를 통한 안정적 처리 구조 설계

### 3. CRM 데이터 동기화 (HubSpot ↔ Salesforce)

- Company → Account  
- Meetings → MeetingLog__c  

외부 데이터(JSON)를 파싱하여  
Salesforce 데이터 모델에 맞게 매핑 및 저장

### 4. Batch 기반 대량 데이터 처리

- IsConverted__c 기준 처리 대상 관리  
- Upsert 기반 데이터 반영  
- Governor Limit을 고려한 비동기 처리 구조  

### 5. LWC 기반 회의록 조회 기능

- Account Name 기반 검색 필터  
- 전체 조회 / 조건 조회 지원  
- Apex 연동(Wire / Imperative)  

### 6. 공통 엑셀 다운로드 모듈

- SheetJS 기반 엑셀 생성  
- LWC → Aura → Visualforce 구조로 공통화  

👉 여러 화면에서 재사용 가능한 다운로드 기능 구현  

<br/>

## 🔨 프로젝트 구조

### 데이터 흐름 아키텍처

```
[HubSpot]
    ↓ (REST API)
[Apex Callout]
    ↓
[IF Object (Staging)]
    ↓ (Batch Apex)
[Salesforce Object]
    ↓
[LWC UI / Excel Download]
```

주요 객체:
- IF_Account / IF_MeetingLog__c (Staging)
- Account / MeetingLog__c (Real Object)

<br/>

## 🔧 Stack

### Backend (Integration & Processing)

**Language**  
Apex  

**Core Features**  
- HTTP Callout  
- Batch Apex  
- JSON Parsing  

**Data Layer**  
- Salesforce Object  
- Custom Metadata  

### Frontend (UI)

**Framework**  
- Lightning Web Components (LWC)  
- Aura Components  
- Visualforce Page  

### Integration & Security

- HubSpot CRM API  
- OAuth 2.0 (Authorization Code Flow)  
- Named Credential / Auth Provider  
- Access Token (Legacy → 개선 경험 포함)

### Library

- SheetJS (xlsx.js)

<br/>

## 💡 경험 및 성과

- **인증 방식 고도화 역량:** Access Token 방식과 OAuth 2.0 방식의 차이를 실무적으로 구현하며 엔터프라이즈 보안 표준에 대한 이해도 제고
- **데이터 아키텍처 설계 능력:** 분리된 처리 구조(IF -> Batch -> Real)를 통해 데이터 유실 방지와 대량 데이터 처리 시 발생할 수 있는 Governor Limits 대응 전략 수립
- **프레임워크 간 연계 및 모듈화:** LWC와 기존 프레임워크(Aura/VF)를 조합하여 플랫폼 제약을 극복하고 재사용 가능한 공통 유틸리티를 구축하는 아키텍처 역량 확보

<br/>

## 🙋‍♂️ Team

| 역할 | 이름 |
|------|------|
| **Salesforce Developer (Solo)** | **김은수** |

---

**본 프로젝트는 단순히 데이터를 연결하는 것을 넘어, 보안과 안정성 그리고 유지보수성을 고려한 표준 인터페이스 모델을 제시합니다.**
