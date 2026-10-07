# Patches utilizados

Somente KSUN + SUSFS são integrados ao Android 12 / 5.10 LTS.

## SUSFS

O patch `50_add_susfs_in_gki-android12-5.10.patch`, `fs/susfs.c` e os
headers são lidos do mesmo checkout da branch `gki-android12-5.10` de
<https://gitlab.com/simonpunk/susfs4ksu>. O build testa todos os hunks com
`--fuzz=0` antes de aplicar o patch e registra a revisão usada.

O fork <https://github.com/pershoot/KernelSU-Next/tree/dev-susfs> já traz
a integração do lado do KSUN. O antigo `static.patch` foi removido porque
suas declarações `static` já foram substituídas por `SUSFS_EXPORT` upstream;
reaplicá-lo no commit `feb0f83b` falhava com `Hunk #1 FAILED at 35`.
O Kbuild atual também já removeu o bloqueio de configuração durante `mrproper`;
não é necessário reaplicar a adaptação antiga do WildKernel.

## Compatibilidade das ferramentas de compilação

`resolve-btfids-host-flags.patch` vem de
[WildKernels/GKI_KernelSU_SUSFS, revisão e0ecd612](https://github.com/WildKernels/GKI_KernelSU_SUSFS/blob/e0ecd61219baaa0c3eae821246e31136302fd0dc/.github/actions/btf/patches/0002-resolve_btfids-inherit-host-linker-flags.patch).
Ele transmite os flags de compilação e link do host ao `resolve_btfids` e
ao libbpf, preservando o sysroot e o linker do toolchain GKI. Não habilita
BTF nem acrescenta um recurso ao kernel.

O patch é aplicado estritamente ou reconhecido como já integrado. Se o
contexto mudar, o build falha para permitir sua atualização explícita.
Patches de outros kernels, versões antigas de SUSFS e recursos extras
do WildKernel não são aplicados.
