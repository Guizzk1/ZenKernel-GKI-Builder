# ZenKernel GKI Builder

Build automatizado do ZenKernel para o Moto G73 5G com Stock ROM.

O builder sincroniza o Android Common Kernel, integra KSUN + SUSFS, compila
o `Image` ARM64 e o empacota com o instalador
[AnyKernel3-ZenKernel](https://github.com/Guizzk1/AnyKernel3-ZenKernel/tree/gki-2.0).

## Alvo

- Android 12 GKI
- Kernel 5.10 LTS
- Fontes: `kernel/common`, branch `android12-5.10-lts`, com o manifest
  `common-android12-5.10-lts` e seu toolchain oficial
- Variante normal, com verificação padrão de compatibilidade dos módulos

## Recursos

- [KernelSU Next](https://github.com/pershoot/KernelSU-Next), sempre a partir do HEAD da branch `dev-susfs`
- [SUSFS](https://gitlab.com/simonpunk/susfs4ksu), branch `gki-android12-5.10`

Nenhum patch adicional de rede ou desempenho é aplicado.
Os patches de integração vêm da mesma revisão do SUSFS que fornece `susfs.c`
e seus headers. Não são reaplicados patches antigos já incorporados pelo
fork pershoot. Consulte [PATCHES.md](PATCHES.md) para a correção das ferramentas
de compilação baseada no WildKernel.

## Compilar

Em **Actions → Build ZenKernel → Run workflow**, mantenha **KSUN+SUSFS**.
O modo **Action** gera um artefato; **Pre-Release** e **Release** também
publicam o ZIP original em Releases após o build passar.

Kernel, KSUN e SUSFS usam as branches atuais por padrão. O campo opcional
`susfs_commit` aceita um SHA completo para reproduzir uma revisão específica.
O resumo registra os commits efetivamente usados, inclusive o do SUSFS.
Pull requests que alteram `.github/` também executam a compilação, sem publicar
uma release.

Fontes verificadas em 6 de outubro de 2026:

| Componente | Versão | Commit |
| --- | --- | --- |
| Android 12 / 5.10 LTS | 5.10.269 | `d83b86f268065fd1d8d2f13aadfefe765bed86e3` |
| pershoot KernelSU Next (`dev-susfs`) | v3.4.0 / 33331 | `feb0f83ba1ec6e7271c3cee98147ded22188b7ef` |
| SUSFS (`gki-android12-5.10`) | v2.3.0 | `9892175b4acec7ee844e113b8d02c0f4d12cdfac` |

Esses números documentam as fontes verificadas; não fixam versões futuras.
O build completo com o toolchain oficial passou, incluindo a comparação de
KMI e da lista de módulos, a verificação dos recursos na `.config` e o teste
de integridade do ZIP gerado. A execução de um build não verifica o boot
no aparelho.

## Saída

Cada build publica somente um ZIP flashável no formato:

```text
ZenKernel-<versão-real>-android12-lts-KSUN<versão>-SUSFS<versão>.zip
```

A versão real é lida de `kernel/common/Makefile`, e o resumo registra o
`kernelrelease` compilado, os commits usados e o SHA-256 do ZIP.
Ao baixar o artefato pelo Actions, extraia o ZIP do artefato e use o
`ZenKernel-*.zip` contido nele. Releases disponibilizam esse arquivo diretamente.
A publicação preserva os bytes e permissões do ZIP criado no build e verifica
seu SHA-256, sem reempacotar o instalador.

O build verifica os recursos solicitados na `.config` gerada, mantém
`CONFIG_MODVERSIONS=y`, usa páginas de 4 KiB e falha se houver patches rejeitados.
Em caso de falha de compilação, os logs e a configuração ficam disponíveis
no artefato `android12-5.10-build-diagnostics`.

## Créditos

- KernelSU Next: pershoot e contribuidores do KernelSU Next
- SUSFS: simonpunk
- AnyKernel3: osm0sis e contribuidores do AnyKernel3
- Referência de integração e compatibilidade: WildKernels

## Aviso

Desbloquear o bootloader e instalar kernels personalizados envolve risco. Faça
backup do boot original e confirme a compatibilidade antes de aplicar o ZIP.
