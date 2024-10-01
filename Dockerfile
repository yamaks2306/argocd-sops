ARG ARGOCD_VERSION="v2.12.3"
FROM quay.io/argoproj/argocd:$ARGOCD_VERSION
ARG SOPS_VERSION="3.9.0"
ARG AGE_VERSION="v1.2.0"
ARG HELM_SECRETS_VERSION="4.6.0"
ARG KUBECTL_VERSION="1.30.2"
ENV HELM_SECRETS_BACKEND="sops" \
    HELM_SECRETS_HELM_PATH=/usr/local/bin/helm \
    HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/" \
    HELM_SECRETS_VALUES_ALLOW_SYMLINKS=false \
    HELM_SECRETS_VALUES_ALLOW_ABSOLUTE_PATH=false \
    HELM_SECRETS_VALUES_ALLOW_PATH_TRAVERSAL=false \
    HELM_SECRETS_WRAPPER_ENABLED=false \
    ARGOCD_USER_ID=999

USER root
RUN apt-get update && \
    apt-get install -y \
      curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fsSL https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

RUN curl -fsSL https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64 \
    -o /usr/local/bin/sops && chmod +x /usr/local/bin/sops

RUN curl -fsSL https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz \
    -o age-${AGE_VERSION}-linux-amd64.tar.gz && \
    tar xzvf age-${AGE_VERSION}-linux-amd64.tar.gz && \
    mv age/age /usr/local/bin/age && chmod +x /usr/local/bin/age && \
    rm -rf age/ && \
    rm age-${AGE_VERSION}-linux-amd64.tar.gz
    
RUN ln -sf "$(helm env HELM_PLUGINS)/helm-secrets/scripts/wrapper/helm.sh" /usr/local/sbin/helm

USER $ARGOCD_USER_ID

RUN helm plugin install --version ${HELM_SECRETS_VERSION} https://github.com/jkroepke/helm-secrets
