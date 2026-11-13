# Blockhaven

브라우저에서 돌아가는 블록 샌드박스 게임입니다. 파일 하나(`blockhaven.html`)에 모든 코드가 들어 있고, 3D 렌더링은 three.js r128(cdnjs CDN)을 씁니다.

## 실행 방법
- `blockhaven.html`을 브라우저로 열면 바로 플레이할 수 있습니다(인터넷 연결 필요: three.js를 CDN에서 불러옴).
- 마우스로 화면을 보고, WASD로 이동, Space로 점프합니다. 왼쪽 클릭을 누르고 있으면 블록을 캐고 클릭하면 공격, 오른쪽 클릭은 블록 설치/아이템 사용입니다. E는 작업대(크래프팅), 1–9와 마우스 휠은 핫바 선택, F는 비행, T/Enter는 채팅입니다.

## 지금까지 들어간 기능
- **월드**: 64×40×64 크기의 섬입니다. 시드로 노이즈 지형을 만들고 나무, 해변, 바다, 구름을 배치합니다. 16×16 청크 단위로 메시를 만듭니다.
- **블록 1–13**: 잔디, 흙, 돌, 모래, 원목, 잎, 판자, 벽돌, 유리, Lumen Block, Fluff Block, Diamond Ore, Diamond Block.
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
10. **Input, 게임 루프(`frame`)**
11. **Online**: 공유 월드, 다른 플레이어 아바타, 채팅, 주먹질 동기화

## 온라인 기능에 대해 꼭 알아둘 점
멀티플레이는 claude.ai 아티팩트 플랫폼 기능인 `window.claude.use("db" | "room" | "user")`를 사용합니다.
- `db`: 월드를 저장합니다. `world/meta` 문서에 `{seed, epoch, t0}`가 있고, `world/c0` ~ `world/c15` 문서에 청크별로 바뀐 블록 목록이 들어 있습니다.
- `room`: 실시간 통신에 씁니다. 블록 변경은 `edit` 이벤트로, 위치·시선·채팅(`say`)·휘두르기(`sw`)·주먹질(`pu`)은 presence로 주고받습니다.
- `user`: 이름과 색상을 가져옵니다.

**이 기능들은 claude.ai 아티팩트 안에서만 동작합니다.** 파일을 직접 열거나 GitHub Pages 같은 곳에 올리면 `window.claude`가 없어서, 게임은 자동으로 혼자 하는 모드(localStorage 저장)로 돌아갑니다.
claude.ai 바깥에서 멀티플레이를 하려면 `goOnline()`과 `online.*` 부분을 Firebase, Supabase, WebSocket 서버 같은 다른 실시간 백엔드로 바꿔야 합니다.

## 원본 아티팩트
https://claude.ai/artifact/2ED8uUx3QqaiNTroMb4zZ7
