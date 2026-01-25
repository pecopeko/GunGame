# agents.md

## 1. Title & Summary

### タイトル
**Tactical Sites: Turn Card Ops**（仮）

### サマリー
- VALORANTの「サイト取り・索敵・スモーク・スタン・トラップ」だけを抽出し、**カード=ユニット5体編成**で戦う**交互手番のターン制ストラテジー**。
- マップは**20マスのグリッド**上に **A / Mid / B** の3エリアを配置。
- 勝利条件はVALORANT準拠：
  - **殲滅**
  - **爆弾設置（1手番）→爆発**
  - **解除（2手番）**
- 基本設計思想：
  - **視界情報が最強**（先に見えた方が相手を一撃で倒せる）
  - ただし **スモークから出た直後** と **ドローンでタグ付け中** は「先見え優位」を失う

---

## 2. Scope / Non-goals

### Scope
- 1vs1（プレイヤー同士 or ローカル対戦）
- 5ユニット編成（4ロールから自由構成）
- 20マスの固定マップ1種（まずは）
- ターン制、スキル、視界、爆弾（設置/解除）
- Flutter + Flame による iOS向け実装

### Non-goals
- [ASSUMPTION] 初期版ではオンライン対戦（マッチメイク/同期/リプレイ共有）は非対応（後続で拡張可能な設計は入れる）
- キャラクター固有の世界観/ボイス/スキン/課金要素は対象外
- VALORANT既存マップのコピーはしない（雰囲気のみ）

---

## 3. Pillars & Target Player

### Pillars
- **情報戦**：ドローン/カメラ/トラップ/スモークで「見える・見えない」を作る
- **短い意思決定**：1手番で1ユニットだけ動かす（テンポ重視）
- **戦術的レーン**：A / Mid / B の分岐
- **逆転性**：スモーク出口不利・ドローンでのタグ付け、スタンでピーク有利を制御

### Target Player
- タクティカルFPSの戦略要素が好きだが、撃ち合い操作が苦手/不要な層
- 1試合をテンポよく回したいストラテジー層

---

## 4. Core Loop
1. 編成（5枚=5ユニット、ロール選択）
2. 初期配置もユーザが好きに決めれる
3. 手番を交互に進める（各手番：1ユニットを選び1アクション）
4. 情報（視界）を取り、サイトを取り、設置/解除 or 殲滅を狙う
5. 勝敗確定 → リザルト → 次試合

---

## 5. Mechanics & Controls

### 5.1 ターン構造
- **手番（Turn）**：片方のプレイヤーが「自軍ユニット1体」に対して**1アクション**指示する
- **ラウンド（Round）**：一回の勝敗が決まる単位。爆弾が爆破するか50ターン以内に相手を殲滅させられれば攻撃側の勝利。爆弾を解除するか、50ターン以内に殲滅させられていないかつ爆弾設置もされていなければ防衛側の勝利。
  - 50ターンが終了したら→ 次ラウンドへ

### 5.2 基本アクション一覧
| アクション | 内容 | 備考 |
|---|---|---|
| Move | 移動力分だけマス移動 | 斜め移動なし |
| Attack | 射程内の敵を攻撃 | ルールは戦闘解決に従う |
| Skill 1 / 2 | ロール固有スキル | クールダウン/チャージあり |
| Plant | 爆弾設置（1手番） | A/Bサイトの設置マスのみ |
| Defuse | 解除進行（1手番で50%） | 2回の成功で解除 |

### 5.3 移動
- グリッド：**7行 x 7列 = 49マス**
- 移動はマンハッタン（上下左右）
- タイル種別：
  - **Floor**：通行可
  - **Wall**：通行不可、視界遮断
  - **SiteTile**：設置/解除可能
  - **Mid**：名称上のエリア（タイル属性で区別）

### 5.4 視界と索敵
- Fog of War：**敵ユニットは、視界で見えない限り表示されない**
- 視界（LoS）：
  - [ASSUMPTION] 視界は「直線（上下左右）＋距離」方式（簡易）
  - 視界距離：無制限
  - **Wall**と**Smoke**は視界遮断
- 追加の可視化：
  - ドローン/カメラ/トラップ発動で一時的に視界を得る

### 5.5 戦闘解決
「先に見えている方が打ち勝てる」を**決定論**で実装する。
ただし、ドローンやカメラで捕捉されてる時と、スタンが当てられてる時はその効果はなくなる。

#### 用語
- **Seeing**：攻撃側が対象を視界内に捉えている
- **SeenByTarget**：対象が攻撃側を視界内に捉えている
- **FirstSightAdvantage**：Seeing かつ SeenByTarget=false のとき得られる優位
- 例外：攻撃側が以下状態のとき、FirstSightAdvantageは無効
  - **SmokeExitPenalty**
  - **DroneTagged**

#### Combat Score方式
- 攻撃時に **攻撃スコア** と **防御スコア** を比較して結果を決める
- 基本：
  - 攻撃スコア = `BaseCombat(2)` + 修正
  - 防御スコア = `BaseCombat(2)` + 修正
- 修正値：
  - FirstSightAdvantage：攻撃スコア +2（ただし例外状態なら付与しない）
  - TargetBlinded：防御スコア -2
  - TargetStunned：防御スコア -3（ほぼ確殺）
  - AttackerSmokeExitPenalty：攻撃スコア -1（かつ FirstSightAdvantage無効）
  - AttackerDroneTagged：攻撃スコア -1（かつ FirstSightAdvantage無効）
  - CoverTile（壁沿い等の「カバー」）：防御スコア +1
    - [ASSUMPTION] 初期版は「カバー無し」で開始し、後からタイル属性で追加可能
- 結果：
  - 攻撃スコア > 防御スコア：**対象撃破**
  - 攻撃スコア < 防御スコア：**攻撃者撃破（返り討ち）**
  - 同値：**相打ち（両者撃破）**

---

## 6. Progression & Difficulty

### 6.1 1ラウンドの長さ
- [ASSUMPTION] 最大 **50ターン**
- 50ターン到達時：
  - Spike未設置：**防衛側勝利**
  - Spike設置済：タイマー継続、爆発まで進行（下記）

### 6.2 Spikeタイマー
- 設置成功後、**１６ターン後に爆発**（解除が間に合わなければ攻撃側勝利）
  - [ASSUMPTION] 8ターンは仮。短すぎる/長すぎる場合は調整

### 6.3 メタ進行
- [ASSUMPTION] 初期版はメタ進行なし（ランク/解放なし）
- 後続拡張候補：
  - マップ追加
  - ロール追加
  - デッキプリセット枠
  - チュートリアル/チャレンジ

---

## 7. Scenes & UI Specs

### 7.1 画面一覧
- MainMenu
- DeckSelect
- MatchSetup
- GameBoard
- Result
- Settings

### 7.2 GameBoard UI
- 上部HUD
  - 現在ラウンド数 / 手番プレイヤー
  - 起動残数（自軍：残り何体未起動か）
  - Spike状態（未所持/所持者/設置済/解除進行%/爆発まで残りラウンド）
- 盤面
  - タイル表示（A/Mid/Bのラベル、Siteタイル強調）
  - ユニット表示（味方は常時、敵は可視時のみ）
  - ハイライト
    - 選択中ユニット
    - 移動可能タイル
    - 攻撃可能ターゲット
    - スキル範囲
    - スモーク範囲（半透明）
- 下部アクションバー（Overlay）
  - Move / Attack / Skill1 / Skill2 / Plant/Defuse / Pass
  - 選択アクションの説明（小）

### 7.3 操作
- タップ：ユニット選択、タイル指定、ターゲット指定
- ロングタップ：タイル情報（スモーク残り、トラップ有無、サイト等）
- 2本指タップ：設定/終了（任意）

---

## 8. Navigation Flow

（mermaid）
    flowchart TD
      A[MainMenu] --> B[DeckSelect]
      B --> C[MatchSetup]
      C --> D[GameBoard]
      D --> E[Result]
      E --> A
      A --> F[Settings]
      F --> A

---

## 9. Client-side Data Model

### 9.1 基本型
- TeamId: attacker | defender
- Role: entry | recon | smoke | sentinel
- TileType: floor | wall | siteA | siteB | mid
- ActionType: move | attack | skill1 | skill2 | plant | defuse | pass
- StatusType：
  - stunned
  - blinded
  - smokeExitPenalty
  - droneTagged
  - revealed（一時的に位置が分かる）
  - trapped（移動抑制）

### 9.2 エンティティ

#### Tile
- id: String（例 "r2c3"）
- row: int, col: int
- type: TileType
- walkable: bool
- blocksVision: bool（wall/smoke）
- zone: String（"A" "Mid" "B"）

#### UnitCard
- cardId: String
- role: Role
- displayName: String
- maxHp: int（[ASSUMPTION] 1）
- moveRange: int
- attackRange: int（[ASSUMPTION] 3）
- skill1: SkillDef
- skill2: SkillDef

#### UnitState
- unitId: String
- team: TeamId
- card: UnitCard
- hp: int
- posTileId: String
- alive: bool
- activatedThisRound: bool
- statuses: List<StatusInstance>
- cooldowns: Map<SkillSlot,int>（残りラウンド）
- charges: Map<SkillSlot,int>（残弾）

#### StatusInstance
- type: StatusType
- remainingTurns: int（ターン or ラウンド単位を統一）
- [ASSUMPTION] 「手番単位」で減少：そのユニットの行動開始時に減る、もしくはラウンド終了時に減る

#### SpikeState
- state: unplanted | carried | planted | defused
- carrierUnitId?: String
- plantedSite: siteA | siteB
- plantedTileId?: String
- explosionInRounds?: int
- defuseProgress: 0 | 1（2回で完了）
- defusingUnitId?: String（連続解除判定に使用）

#### GameState
- seed: int（将来の乱数/リプレイ用、ただし初期は決定論）
- roundIndex: int（1..）
- turnTeam: TeamId
- phase: Phase
- map: MapState
- units: List<UnitState>
- spike: SpikeState
- log: List<TurnEvent>（デバッグ/リプレイ）

---

## 10. Game State Machine

（mermaid）
    stateDiagram-v2
      [*] --> Boot
      Boot --> MainMenu
      MainMenu --> DeckSelect
      DeckSelect --> MatchSetup
      MatchSetup --> SetupPlacement
      SetupPlacement --> RoundStart

      RoundStart --> TurnStart
      TurnStart --> SelectUnit
      SelectUnit --> ChooseAction
      ChooseAction --> ResolveAction
      ResolveAction --> CheckWin

      CheckWin --> Result: win/lose
      CheckWin --> NextTurn: continue

      NextTurn --> TurnStart: swap team
      NextTurn --> RoundEnd: both teams exhausted
      RoundEnd --> RoundStart

      Result --> MainMenu

### フェーズ補足
- SetupPlacement：スポーン内で5体配置、攻撃側はSpikeキャリアを選ぶ
- ResolveAction：移動/攻撃/スキル/設置/解除を解決し、ステータス更新
- RoundEnd：activatedThisRound=falseへリセット、スモーク等の持続を減算

---

## 11. Components & Modules

### 11.1 Flame構成
- TacticalGame extends FlameGame
- WorldLayer
  - GridComponent
  - TileComponent x20
  - SmokeAreaComponent（複数）
  - TrapComponent（複数）
  - CameraBeaconComponent（複数）
  - UnitComponent（最大10）
  - FogOfWarComponent（チーム別マスク）
- OverlayLayer
  - HUD Overlay（Flutter Widget）
  - ActionBar Overlay
  - Tooltip Overlay
  - Debug Overlay（開発用）

### 11.2 ロジックモジュール
- TurnManager
  - 手番管理、起動済み判定、ラウンド遷移
- RulesEngine
  - 行動合法手チェック
  - 戦闘解決（Combat Score）
  - ステータス付与/減算
  - Spike設置/解除/爆発処理
- VisionSystem
  - LoS計算（壁/スモーク遮断）
  - 可視敵の抽出
  - revealedの統合
- Pathing
  - BFSで移動可能タイル算出（20マスなので軽い）
- UiPresenter
  - 選択中ユニット、範囲ハイライト、説明文生成
- GameSerializer
  - GameStateのJSON化（後でオンライン/リプレイに転用）

---

## 12. Content & Assets List

### 12.1 必須アセット
- タイル（floor/wall/siteA/siteB/mid）各1
- ユニット駒（ロール4種 x チーム2色 = 8）
- アイコン
  - Move / Attack / Plant / Defuse
  - ステータス（Stun/Blind/Tagged/SmokeExit/Trap/Reveal）
  - スキル4ロール分（8つ）
- VFX
  - スモーク半透明円/タイル覆い
  - スタン/フラッシュ演出（軽量）
  - ドローン/カメラのマーキング
- SFX（任意）
  - タップ/決定/撃破/設置/解除

### 12.2 マップ定義
- map_01.json（タイル属性と壁配置）

---

## 13. Performance & Quality Targets
- iOS（iPhone 12相当）で 60fps
- 盤面は最大10ユニット、タイル20、軽量VFXのみ
- 1手番操作は 300ms以内 に視界/範囲/ハイライト更新
- 例外や不正操作時もクラッシュしない（合法手のみUIで出す）

---

## 14. Accessibility & Localization

### 色弱配慮：
- チーム色だけに依存しない（形状/枠線/アイコン）

### テキスト：
- 日本語をデフォルト
- [ASSUMPTION] 将来英語対応を見越して文字列テーブル化

### 操作補助：
- タイル拡大は無しでも良いが、タップ判定を大きく（最小44pt）

---

## 15. Telemetry/Debug

### Debug機能
- デバッグHUD表示
- 現在のLoS可視タイル
- 各ユニットのStatus一覧と残り
- Spikeタイマー/解除進行
- ターンログ

### TurnEvent
- TurnEvent{team, unitId, action, params, result}


---

## 16. Error & Edge Cases
- 選択ユニットが死亡した後のUI参照 → 選択解除
- 起動可能ユニットがゼロ → 強制Pass→RoundEnd
- Defuse中に
  - 解除者が移動/攻撃/スキル使用 → 解除進行リセット
  - 解除者が撃破 → 解除進行リセット
- Plant中に撃破された場合
  - [ASSUMPTION] Plantは「手番の解決後に成立」するため、Plant手番で返り討ちになった場合は設置失敗
- 相打ちで両者全滅
  - Spike未設置：防衛勝利（時間切れ扱い）
  - Spike設置済：解除/爆発状態に従う（ユニット不在なら解除不可→爆発で攻撃勝利）
- 50ターン到達の同時判定
  - ラウンド終了時に勝利判定（Spike設置済は爆発まで継続）

---

## 17. Risks & Mitigations
- リスク：20マスが狭すぎて戦術が単調  
  - 対策：壁/スモーク/トラップの「配置価値」が出るよう、チョークポイントを明確化
- リスク：先見え優位が強すぎて一方的  
  - 対策：SmokeExitPenalty / DroneTagged により「先見え優位を得られない状態」を設計的に作る
- リスク：ターン制のテンポが悪い  
  - 対策：合法手のみUI提示、1タップで実行、アニメは短く
- リスク：VALORANTのマップコピーに見える  
  - 対策：完全オリジナルの壁配置・比率、固有名称（A/B/Mid以外の呼称も検討）

---

## 18. Work Plan for codeX

### Milestone 1 盤面と手番
- グリッド表示（20マス）
- ユニット配置、選択、移動ハイライト
- 交互手番、ラウンド管理（1ラウンド1回起動制）

### Milestone 2 視界
- Wall遮断のLoS（距離3）
- Fog of War（敵は見えた時のみ表示）

### Milestone 3 戦闘
- Attackアクション
- Combat Score解決
- 撃破処理、勝敗判定（殲滅）

### Milestone 4 スキル実装
- Entry：スタン範囲、移動強化
- Recon：ドローン、フラッシュ
- Smoke：スモーク設置3回、SmokeExitPenalty
- Sentinel：トラップ、カメラ（Reveal）

### Milestone 5 Spikeルール
- 攻撃側キャリア指定、受け渡し（任意）
- Plant（1手番）
- Defuse（2手番、連続条件）
- 爆発タイマーと勝敗

### Milestone 6 UI polish
- HUD/アクションバー
- タイル情報ツールチップ
- デバッグオーバーレイ

---

## 19. Handoff Checklist
- マップ map_01.json 定義（20マス、wall、siteA/siteB/mid）
- ロール4種の UnitCard パラメータ確定
- スキル8種の仕様確定（範囲、持続、CD、チャージ）
- 解除の「連続条件」実装方針確定（同一ユニット/中断条件）
- 視界アルゴリズム（直線＋距離3）の確定
- Combat Score修正値の調整余地を定数化
- 50ラウンド/爆発8ラウンドの数値をバランス調整用に外出し

---

## 付録 A ロール定義案

### 共通ステータス
- HP：1
- AttackRange：3
- MoveRange：2（Entryのみ3）

### ロール別

#### 1) Entry
- パッシブ：MoveRange +1（=3）
- Skill1「Breach Pulse」：指定タイル中心 半径1（十字でも可）をStun 1付与  
  - 射程：2  
  - CD：なし・一回のみ
- Skill2「Dash」：即時に追加で+2マス移動（この手番のMoveに上乗せ）  
  - チャージ：1/ラウンド（ラウンド開始時に1回だけ使える）

#### 2) Recon
- Skill1「Drone Tag」：
  - ドローンを指定タイルへ飛ばし（射程3）、半径1をReveal（1ラウンド）
  - その範囲内に敵がいたら最も近い1体に DroneTagged 2手番 を付与
  - CD：30ターン
- Skill2「Flash」：
  - 指定方向（上下左右）に2マス、最初に見えた敵1体へ Blinded 1手番
  - CD：30ターン

#### 3) Smoke
- Skill1「Smoke」：
  - 指定タイルにスモークを設置（半径0=1タイルでも可）
  - 視界遮断、持続：10ターン
  - チャージ：3（試合開始時3、回復なし）
  - 追加効果：
    - スモーク内→外へ移動したユニットに SmokeExitPenalty 1手番

#### 4) Sentinel
- Skill1「Trap」：
  - 指定タイルに罠設置（持続：3ラウンド）
  - 敵が踏むと Trapped 1手番（移動不可）＋Reveal 1手番
  - チャージ：2（ラウンド開始時+1、最大2）
- Skill2「Camera」：
  - 指定タイルにカメラ設置（射程2、持続：7ターン）
  - カメラの視界距離2で敵を見つけたら、その敵を Reveal（その手番中）
  - CD：30ターン

---

## 付録 B マップ案 4x5
- 座標：(row 0..3, col 0..4)
- 左が攻撃スポーン、右が防衛スポーン
- Aは上、Bは下、Midは中央寄り
- 例（W=Wall, .=Floor, A=SiteA, B=SiteB, M=Mid）

（makefile）
    r0: .  W  A  .  .
    r1: .  .  M  W  .
    r2: .  W  M  .  .
    r3: .  .  B  W  .

- [ASSUMPTION] スポーン
  - 攻撃：col=0 の r1,r2 を優先（2マスをスポーン基点、周辺も許可可）
  - 防衛：col=4 の r1,r2 を優先
- 設置可能タイル：A / B の各1タイル（将来2タイルに拡張可）


# コーディング規約：ファイルサイズ制限

- **原則:** 1ファイルの行数は500行未満に保つこと。
- **アクション:** 500行を超えそうな場合、または超えているファイルを編集する場合は、必ずファイルを論理的な単位（関数、クラス、コンポーネント）で分割・リファクタリングすることを優先してください。
