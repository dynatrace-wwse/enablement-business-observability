#!/bin/bash

# VARIABLES DECLARATION
source $REPO_PATH/.devcontainer/util/variables.sh

echo -e "${thickline}"
echo -e ""
echo -e "      ${CYAN}                 Welcome to your your Dev Container                ${RESET}                "
echo -e "       This enablement was made with ${RED}${HEART}${RESET} from the Dynatrace SE Center of Excellence Team                                                                                             "
echo -e "${GREEN} "
echo -e "      ${CYAN}.oyyyyyson+${GREEN}.          sh                               hs                                                         "
echo -e "  ${CYAN}.:yhhhhhhhhh/ ${GREEN}oy.   .:HHHHhd /:      /: .:HHH:.   :mHHHm.  dh//-  .mmmm. -mHHHm:   -HHHH.   .:HHHH:.                  "
echo -e "  ${BLUE}s.${CYAN}  PPPPPPP ${GREEN}nhhh   od/----yd /m:    sd./d+:  \dy       :do dh    .ms          :do dy:      sd/     d+                 "
echo -e "  ${BLUE}hhh.       ${GREEN}ohhhh-  m+     sd  om-  +m- hh     oN. -:mmm:ym dy    -N/    -:mmmm:ym N.       my:mmmdh*                  "
echo -e "  ${BLUE}hhh        ${GREEN}shhhh:  m+     sd   sd./m/  hh     oN-hh:    ym dy    -N/   .ds    -ms N.       my                         "
echo -e "  ${BLUE}hy ${LILA}::::::: ${GREEN}yhhho   od/---:dh    hdm+   hh     oN-dh:    hh yd:-- -N/   .mo    :mo dy:----  sd:                        "
echo -e "  ${BLUE}/ ${LILA}yhhhhhhh-${GREEN}hh+.     .:HHHH:     -Ns    hh     oN  :HHHHH:   :HHH:-N/    .HHHHHH:   -HHHHH.   *HHHH*                   "
echo -e "   ${LILA}.osyyhhhh+${GREEN}/*                   yy                                                                                    "
echo -e "${NORMAL}                                                                                                               "
echo -e "${thickline}"                                                                       
echo -e "  ${CYAN}   General System Information of your dev.container          ${RESET}             "
echo
echo -e " ${LILA}OS & Kernel Version    ${NORMAL}       "
uname -a
echo
echo -e " ${LILA}Kubernetes Cluster ${NORMAL}       "
kubectl version
echo -e "                                                                                                             "
echo -e "${RESET}${thinline}"                                                                     
echo -e "                                                                                                             "
echo -e " ${LILA}GitHub Pages: ${RESET}https://dynatrace-wwse.github.io/${RepositoryName}    "
echo -e " ${LILA}GitHub Repository: ${RESET}$(git remote get-url origin)     "
echo -e " ${LILA}Dynatrace Tenant: ${RESET}${DT_TENANT}"
echo -e "                                                                                                             "
echo -e " ${LILA}Codespace information: ${NORMAL}   "
echo -e "Codespace ${RESET}${CODESPACE_NAME}${NORMAL} running for user ${RESET}${PRINT_USER}    "
echo -e "                                                                                                             "
echo -e "${CYAN}This devcontainer is exposing the following processes:${RESET} "
echo -e "  ${LILA}Web App UI:${RESET} ${WEBAPP_URL} "
echo -e "                                                                                                             "
echo -e "${CYAN}This container has the following tools installed and configured for your best experience:${RESET} "
echo -e "  ${RESET}k9s kubectl helm node jq python3 gh ${RESET} "
echo -e "                                                                                                             "
echo -e "${CYAN}If you want to make the endpoints public accesible, just go to the ports section in VsCode, right click on them and change the visibility to public ${NORMAL}"
echo -e "${CYAN}When you are finished with your codespace, you can comfortably delete it by typing in the Terminal${RESET} deleteCodespace"
echo -e "                                       " 
if [[ $CODESPACES == true ]]; then
    if [ "$ERROR_COUNT" -gt 0 ]; then 
        echo -e "${RED} There has been $ERROR_COUNT errors detected in the creation of the codespace, type ${RESET}verifyCodespaceCreation${RED} to understand more. ${RESET}                          " 
    else
        echo -e "${GREEN} There has been no errors detected in the creation of the codespace. ${RESET}                          " 
    fi
else 
    echo -e "${BLUE} You are running the enablement in a container, amazing! at the moment automatic error detection on creation is not implemented.${RESET}                " 
fi
echo -e "${thinline}"