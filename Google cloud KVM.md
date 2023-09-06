# Google cloud KVM settings

```bash
gcloud compute instances create kvm1 \
    --zone=us-central1-a \
    --min-cpu-platform="Intel Haswell" \
    --image-project=ubuntu-os-cloud \
    --image=ubuntu-2004-focal-v20220610 \
    --boot-disk-size 200GB \
    --machine-type=n1-standard-16 \
    --enable-nested-virtualization

>> ls /dev/kvm
/dev/kvm

>> egrep -c '(vmx|svm)' /proc/cpuinfo
32

>> sudo apt install cpu-checker
>> sudo kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
```
