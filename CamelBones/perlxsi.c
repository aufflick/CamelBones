#include "perlxsi.h"

EXTERN_C void
xs_init(pTHXo)
{
	char *file = __FILE__;
	dXSUB_SYS;

	newXS("DynaLoader::boot_DynaLoader", boot_DynaLoader, file);
}
