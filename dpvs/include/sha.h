#include <stdio.h>
#include <linux/if_link.h>

#define SHA1_DIGEST_SIZE        20
#define SHA1_DIGEST_WORDS	(SHA1_DIGEST_SIZE / 4)
#define SHA1_WORKSPACE_WORDS	16

void sha1_init(__u32 *buf);
void sha1_transform(__u32 *digest, const char *data, __u32 *W);







































