# Auto-update to latest v5.10 - integration instructions

Este commit adiciona um script utilitário que detecta a última tag v5.10.*
no repositório linux-stable (ou no remoto que você configurar) e exporta as
variáveis KERNEL_TAG e KERNEL_SUBLEVEL que podem ser usadas pelo seu fluxo de
build/CI para clonar a tag correta e aplicar patches condicionais por sublevel.

Arquivos adicionados:
- scripts/detect_5_10_tag.sh  - script que detecta a tag mais recente e exporta variáveis.

Como integrar no seu build local / CI

1) Uso simples (no seu script de build):

   # detecta a tag e define variáveis no ambiente
   source "${PWD}/scripts/detect_5_10_tag.sh"

   # clona o kernel usando a tag detectada
   git clone --depth=1 --branch "$KERNEL_TAG" "$KERNEL_REMOTE" kernel || {
     # fallback se o clone com --branch falhar
     git clone "$KERNEL_REMOTE" kernel
     git -C kernel fetch --tags
     git -C kernel checkout "$KERNEL_TAG"
   }

   # exporta o sublevel para passos seguintes
   export KERNEL_SUBLEVEL

2) Integração com GitHub Actions (exemplo em workflow):

   - name: Detect kernel tag
     run: |
       ./scripts/detect_5_10_tag.sh > kernel_tag.out
       echo "KERNEL_TAG=$(grep '^KERNEL_TAG=' kernel_tag.out | cut -d= -f2-)" >> $GITHUB_ENV
       echo "KERNEL_SUBLEVEL=$(grep '^KERNEL_SUBLEVEL=' kernel_tag.out | cut -d= -f2-)" >> $GITHUB_ENV

   Depois passe KERNEL_SUBLEVEL como input para actions composite que aplicam patches:

   - name: Apply NTSync
     uses: ./.github/actions/ntsync
     with:
       version: android12-5.10
       kernel_version: 5.10
       sublevel: ${{ env.KERNEL_SUBLEVEL }}

3) Observações sobre patches

- Os patchers que dependem de sublevel (como os compostos em .github/actions do WildKernels)
  devem receber o sublevel (KERNEL_SUBLEVEL) para decidir que backports/fixes aplicar.
- Antes de aplicar um patch, recomendo sempre verificar se ele já foi aplicado (patch --dry-run
  ou grep por trecho alterado) para manter a idempotência.
- Se alguma patch falhar contra a nova sublevel, puxe as correções do WildKernels
  (repo: WildKernels/GKI_KernelSU_SUSFS) ou adapte o patch localmente; o padrão
  deste repositório usa checks condicionais por sublevel, veja .github/actions/* no
  WildKernels para exemplos.

4) Testes
- Execute o build no runner de CI ou localmente e verifique no log se:
  - O passo de detecção imprime KERNEL_TAG=v5.10.<maior>
  - Os patchers recebem KERNEL_SUBLEVEL e aplicam apenas o necessário
- Se um patch falhar, capture o diff do arquivo e eu adapto ou importo a versão
  atualizada do WildKernels.

Commit atual
- Adiciona scripts/detect_5_10_tag.sh e este arquivo de instruções.
- Não alterei outros scripts para evitar editar locais incertos no seu repositório;
  se quiser, eu posso aplicar as substituições automaticamente (procuro pelos
  pontos que usam tags fixas e atualizo).