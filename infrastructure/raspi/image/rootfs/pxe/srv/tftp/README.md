# PXE artifacts

The PXE profile intentionally refuses to start until a versioned `ipxe.efi`
has been staged here. Add the iPXE source commit, build recipe, embedded
`boot.ipxe`, and checksums to the image pipeline before enabling this profile.
