# OCI Free Tier Provisioning

Oracle Cloud Infrastructure Free Tier에 개인용 작업 VM을 만드는 최소 Terraform 구성입니다.
애플리케이션 배포 파일은 포함하지 않고, VM/네트워크/초기 부팅 설정만 관리합니다.

## 구성

- `terraform/provider.tf`: OCI Terraform provider 설정
- `terraform/variables.tf`: 리전, 컴파트먼트, SSH 키, 인스턴스 크기 변수
- `terraform/network.tf`: VCN, public subnet, internet gateway, route table, security list
- `terraform/compute.tf`: Ubuntu ARM64 compute instance
- `terraform/cloud-init.yaml`: 기본 패키지, Docker, Docker Compose, Tailscale, UFW, 작업 디렉터리 설정
- `terraform/outputs.tf`: public IP, private IP, SSH 명령 출력
- `terraform/auto-deploy.sh`: OCI Resource Manager apply 재시도 helper

## Free Tier 기본값

기본값은 OCI Ampere A1 Always Free 범위에 맞춰 둡니다.
Oracle 공식 문서 기준 Always Free 테넌시의 Ampere A1 한도는 총 4 OCPU / 24 GB 메모리이고, boot volume과 block volume 합산 200 GB가 Always Free 범위입니다.

참고: [Oracle Always Free Resources](https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm)

## 로컬 Terraform 실행

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars

terraform init
terraform plan
terraform apply
```

`terraform.tfvars`, `*.tfstate`, `tfplan*` 파일에는 개인 OCI 식별자나 실행 상태가 들어갈 수 있으므로 커밋하지 마세요.
이 저장소의 `.gitignore`는 해당 파일들을 제외하도록 구성되어 있습니다.
`region`은 본인 OCI home region으로, `ssh_ingress_cidr`는 가능하면 본인 공인 IP의 `/32` CIDR로 바꿔서 사용하세요.

## OCI Resource Manager 실행

```bash
cd terraform
zip -r oci-free-tier-provisioning.zip . \
  -x ".terraform/*" \
  -x "*.tfstate*" \
  -x "*.tfvars" \
  -x "*.zip" \
  -x "*.log"
```

OCI Console에서 Resource Manager Stack을 만들고 위 ZIP을 업로드한 뒤 `compartment_id`와 `ssh_public_key`를 입력합니다.
Ampere A1 capacity 부족으로 apply가 실패할 때는 Stack ID를 지정해 재시도 helper를 사용할 수 있습니다.

```bash
STACK_ID=<stack_ocid> ./auto-deploy.sh
```

## 프로비저닝 후

```bash
ssh ubuntu@<PUBLIC_IP>
sudo tailscale up
cd /opt/workspace
docker version
docker compose version
```

기본 보안 규칙은 SSH `22/tcp`, Tailscale `41641/udp`, ICMP만 인바운드로 엽니다.
애플리케이션 포트는 Terraform에 고정하지 않고, 실제 실행 방식에 맞춰 별도로 열거나 Tailscale 내부에서만 사용합니다.
