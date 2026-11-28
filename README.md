# Blockhaven

### ▶ 지금 플레이: **https://blockhaven-w16v.netlify.app**

브라우저에서 돌아가는 블록 샌드박스 게임입니다. 파일 하나(`blockhaven.html`)에 모든 코드가 들어 있고, 3D 렌더링은 three.js r128(cdnjs CDN)을 씁니다.

## 실행 방법
- 이 저장소는 **공개 저장소**여야 Netlify가 여러 사람의 커밋을 배포합니다(무료 플랜은 비공개 저장소에서 기여자 1명만 허용).
- 위 주소로 접속해 아이디·비밀번호로 가입/로그인하면 됩니다. `main` 브랜치에 푸시하면 Netlify가 자동으로 사이트를 다시 배포합니다.
- 로컬에서는 `blockhaven.html`을 브라우저로 열어도 바로 플레이할 수 있습니다(인터넷 연결 필요: three.js와 Supabase를 CDN에서 불러옴).
- **컴퓨터**: 마우스로 화면을 보고, WASD로 이동, Space로 점프합니다. 왼쪽 클릭을 누르고 있으면 블록을 캐고 클릭하면 공격, 오른쪽 클릭은 블록 설치/아이템 사용입니다. E는 작업대(크래프팅), 1–9와 마우스 휠은 핫바 선택, F는 비행, T/Enter는 채팅입니다.
- **iPad / 핸드폰**(터치 화면이면 자동으로 켜짐): 왼쪽 조이스틱으로 이동, 화면을 드래그해 둘러보기. ⛏ 누르고 있기 = 캐기(생물은 탭해서 공격), ✋ = 블록 설치/아이템 사용, ⤒ = 점프(비행 중엔 위로, ⤓ 아래로). 오른쪽 위 🕊 비행 · 🛠 작업대 · ⏸ 일시정지 · 💬 채팅. 화면을 짧게 탭하면 설치, 꾹 누르면 캐기. 핫바 칸을 탭해서 선택. 핸드폰은 가로로 돌리면 화면이 넓어집니다.
- iPhone/iPad Safari에서 공유 → **홈 화면에 추가**를 하면 주소창 없이 전체 화면 앱처럼 실행됩니다.

## 지금까지 들어간 기능
- **월드**: 64×40×64 크기의 섬입니다. 시드로 노이즈 지형을 만들고 나무, 해변, 바다, 구름을 배치합니다. 16×16 청크 단위로 메시를 만듭니다.
- **블록 1–14**: 잔디, 흙, 돌, 모래, 원목, 잎, 판자, 벽돌, 유리, Lumen Block, Fluff Block, Diamond Ore, Diamond Block, TNT.
- **아이템 100–110**: 막대기, 나무/돌/다이아 곡괭이, 나무/돌/다이아 검, Fluff, Gloom Shard, 붕대, 다이아몬드.
- **채굴**: 누르고 있으면 진행됩니다. `pick` 값은 필요한 곡괭이 등급입니다(1=나무, 2=돌, 3=다이아).
- **크래프팅**: `RECIPES` 배열에 레시피가 들어 있고, E를 누르면 작업대 패널이 열립니다.
- **생물**:
  - Hopkin: 낮에 뛰어다니는 순한 생물로, Fluff를 떨어뜨립니다.
  - Gloomling: 밤에만 나와 플레이어를 쫓는 적으로, Gloom Shard를 떨어뜨립니다.
- **체력**: 10칸. 낙하 피해가 있고 시간이 지나면 조금씩 회복됩니다. 쓰러지면 섬 중앙에서 다시 시작합니다.
- **낮/밤**: 하루가 360초인 주기입니다.
- **주먹질**: 빈손 주먹 이미지가 있고, 다른 플레이어를 때릴 수 있습니다(PvP, 밀려남 효과 포함).
- **다이아몬드**: y 1–7 깊이에 광맥으로 생성됩니다.
- **TNT**: 작업대에서 Gloom Shard 3개 + Diamond 1개로 만듭니다. 설치한 TNT를 때리면(왼쪽 클릭 / 터치는 ⛏) 3초 뒤 폭발해 반경 약 3칸의 블록을 부수고(맨 아래층은 남음), 6칸 안의 플레이어와 5칸 안의 생물에게 피해를 줍니다. 근처 TNT는 연쇄 폭발합니다. 멀티플레이에서는 불붙인 사람이 결과를 저장하고, 다른 사람에게는 `lit` 메시지 하나만 보내 각자 화면에서 같은 폭발을 재생합니다. 코드: `// ================= TNT` 부분(`igniteTNT`, `lightFuse`, `explode`).
- **크리에이티브 모드**: 모든 블록·아이템 무한, 한 번에 캐기, 피해 없음. 서바이벌 가방은 따로 보관됐다가 돌아오면 복원됩니다. 일시정지 화면의 "Creative mode" 버튼이나 `/c`(크리에이티브), `/s`(서바이벌). **게스트(혼자 플레이)는 누구나, 공유 섬에서는 관리자만** 쓸 수 있습니다.
- **관리자(admin)**: `world_admins` 테이블에 있는 계정(현재 dylan, dylanipad, dylan_teacher). 이름 옆에 👑가 붙고 채팅 명령을 쓸 수 있습니다. T / Enter / `/` 키(터치는 💬)로 채팅을 열고 `/help`:
  - `/give ITEM [개수] [플레이어]` — 예: `/give tnt 10`, `/give diamond 3 dylanipad`(다른 사람에게는 선물함으로, 서버 함수 `admin_give`가 관리자인지 확인)
  - `/fill X1 Y1 Z1 X2 Y2 Z2 블록` · `/setblock X Y Z 블록` — `~`는 내 위치, `~3`은 내 위치+3, `air`는 지우기. 한 번에 최대 40000칸. 다른 플레이어에게는 `fill` 메시지 하나로 전달됩니다.
  - `/tp 플레이어` 또는 `/tp X Y Z` · `/time day|noon|sunset|night|midnight|시각`(모두에게 적용) · `/heal` · `/clear` · `/spawn hopkin|gloomling [N]` · `/killmobs` · `/newworld confirm`
  - 누구나: `/help`, `/pos`, `/fly`
  - 관리자 추가: `insert into public.world_admins (user_id) select id from auth.users where email = '아이디@players.blockhaven.game';`

## 코드 구조 (`<script>` 안에서 위에서부터 순서대로)
1. **World**: `world` 배열, `get`/`set`, `hash`/`fbm` 노이즈, `generate()`
2. **Textures**: 16px 타일을 4×4로 묶은 아틀라스. `paint(i, fn)`로 타일을 하나씩 그림
3. **Blocks & items**: `BLOCKS`, `ITEMS`, `RECIPES`, 아이콘 생성
4. **Meshing**: `buildChunk`, `rebuildAt`
5. **Particles, UI 헬퍼, 인벤토리(`give`/`take`), 크래프팅 패널**
6. **Save/load**: 혼자 플레이할 때는 월드를 localStorage에 저장
7. **Player**: 물리와 충돌(`step`, `collideBox`), 체력
8. **Mobs**: `makeHopkin`, `makeGloomling`, `updateMob`, `hitMob`, `trySpawn`
9. **Raycast & actions**: `ray`, `target`, `primaryDown`, `breakBlock`, `use`, `editBlock`
10. **Input, 터치 조작(Touch controls: 조이스틱 `stick`, 버튼, 드래그 시점), 게임 루프(`frame`)**
11. **Online**: 공유 월드, 다른 플레이어 아바타, 채팅, 주먹질 동기화

## 계정(로그인)과 캐릭터 저장 — Supabase
- 첫 화면에서 **아이디 + 비밀번호**로 회원가입/로그인합니다. 로그인하지 않고 "Play as guest"로 혼자 할 수도 있습니다(이 브라우저에만 저장).
- 로그인한 캐릭터의 **인벤토리, 핫바, 체력, 위치**가 Supabase `players` 테이블에 5초마다(바뀐 경우에만) 저장되고, 다른 컴퓨터에서 로그인해도 그대로 불러옵니다.
- 캐릭터는 월드와 따로 저장됩니다. "Generate a new world"를 눌러도 로그인한 캐릭터의 가방은 유지됩니다. 월드(블록) 자체는 아직 각 브라우저의 localStorage에 저장됩니다.
- **아이템 선물하기**: 플레이어 가방(`inv`)을 직접 고치면 열려 있는 게임이 자동 저장하면서 덮어쓸 수 있으니, `gift` 칸에 넣으세요. 게임이 로그인할 때와 15초마다 확인해서 가방에 넣고 비웁니다. 예: Supabase SQL Editor에서 `update public.players set gift = gift || '{"14": 5}' where username = 'dylanipad';` (14 = TNT)
- 아이디는 Supabase Auth에서 `아이디@players.blockhaven.game` 형태의 숨은 이메일로 쓰입니다. 그래서 이메일로 비밀번호 찾기는 안 됩니다.
- 코드: `<script>` 맨 아래쪽 **Accounts (Supabase)** 부분(`signIn`, `enterAccount`, `cloudSave`). 접속 정보는 `SUPABASE_URL`, `SUPABASE_KEY`(공개용 publishable key — 브라우저에 넣어도 안전).

### Supabase 처음 설정 (한 번만)
1. Supabase 대시보드 → **SQL Editor** → New query에 [`supabase/setup.sql`](supabase/setup.sql) 내용을 붙여넣고 **Run**.
2. **Authentication → Sign In / Providers → Email**에서 **Confirm email**을 끄고 저장. (가짜 이메일이라 확인 메일을 받을 수 없기 때문)
3. secret key / service_role key는 절대 코드나 저장소에 넣지 마세요.

> 참고: 지금은 아이템 수량을 브라우저가 직접 저장하므로, 마음먹고 개발자 도구를 쓰면 자기 캐릭터의 아이템을 조작할 수 있습니다. 경쟁 요소가 생기면 서버 쪽 검증을 추가해야 합니다.

## 멀티플레이 (Supabase)
**로그인한 플레이어는 모두 같은 섬에서 함께 플레이합니다.** 게스트는 지금처럼 혼자 하는 모드입니다.
- **월드 저장**: `world_docs` 테이블. `meta` 행에 `{seed, epoch, t0}`, `c0` ~ `c15` 행에 청크별로 바뀐 블록 목록이 들어 있습니다. 바뀐 내용은 Realtime(postgres_changes)으로 다른 플레이어에게 전달됩니다.
- **실시간 통신**: Realtime 채널 `blockhaven-room`. 접속자 목록은 presence, 위치·시선·채팅·휘두르기·주먹질은 broadcast(`st`), 블록 변경은 broadcast(`edit`)로 주고받습니다.
- **권한(RLS)**: 로그인한 사람은 누구나 섬을 보고 블록을 바꿀 수 있습니다. `meta`를 바꾸거나 청크를 지우는 것, 즉 "새 월드 만들기"는 `world_admins`에 등록된 사람만 할 수 있습니다.
- 코드: `<script>` 아래쪽 **Online: Supabase backend** 부분(`sbWorldDb`, `sbRoom`, `goOnlineSupabase`). claude.ai 아티팩트와 같은 모양의 `db`/`room`/`user` 인터페이스를 흉내 내므로, 그 위의 게임 코드는 그대로 씁니다. claude.ai 아티팩트 안에서 열면 예전처럼 `window.claude` 기능을 씁니다.
- 몹(Hopkin, Gloomling)은 아직 각자 화면에서 따로 움직입니다(동기화 안 됨).

### 처음 설정 (한 번만)
1. SQL Editor에서 [`supabase/multiplayer.sql`](supabase/multiplayer.sql)을 실행합니다(`setup.sql` 다음에).
2. 관리자를 정하려면 파일 맨 아래 주석의 `insert into public.world_admins ...` 줄에서 `USERNAME`을 바꿔 실행합니다.

## 원본 아티팩트
https://claude.ai/artifact/2ED8uUx3QqaiNTroMb4zZ7
