package main

import (
	"encoding/binary"
	"encoding/json"
	"flag"
	"fmt"
	"github.com/coredns/coredns/middleware/vane/models"
	"log"
	"net"
	"os"
	"runtime"
	"strconv"
	"strings"
)

var dsn = flag.String("dsn", "root:root@tcp(127.0.0.1:3306)/iwg", "mysql dsn")
var natserver = flag.String("nat", "cszx-nat1", "nat server which use export config")

//var outtable = flag.Bool("outtable", true, "load outtable from json to db")
//var srcrule = flag.Bool("src_rule", true, "load src_rule from json to db")
//var addrgroup = flag.Bool("addrgroup", true, "load addrgroup from json to db")
var nat2db = flag.Bool("nat2db", false, "load nat config from json to db")
var db2nat = flag.Bool("db2nat", false, "dump nat config from db to json")
var outlink_only = flag.Bool("outlink", false, "only load outlink from json to db")

type Nat struct {
	AddrGroup map[string][]string `json:"addrgroup"`
	OutLink   map[string][]string `json:"outlink"`
	OutTable  map[string][]string `json:"outtable"`
	SrcRule   []string            `json:"src_rule"`
}

var srcAddrGroup map[string]bool
var NatIn Nat
var NatOut Nat

const rowLimit = -1

func main() {
	fmt.Println(CIDR(" 1.1.11.1/12"))
}

func DB2NAT() {
	NatOut.AddrGroup = make(map[string][]string)
	srcAddrGp := GetClientSetView()
	for k, v := range srcAddrGp {
		NatOut.AddrGroup[k] = v
	}
	srcWLAddrGp := GetClientSetWLView()
	for k, v := range srcWLAddrGp {
		NatOut.AddrGroup[k] = v
	}
	dstWLAddrGp := GetNetlinkWLView()
	for k, v := range dstWLAddrGp {
		NatOut.AddrGroup[k] = v
	}
	dstAddrGp := GetNetlinkView()
	for k, v := range dstAddrGp {
		NatOut.AddrGroup[k] = v
	}
	NatOut.SrcRule = GetSrcView()
	NatOut.OutTable = GetRouteView()
	NatOut.OutLink = GetOutlinkView(*natserver)
	jbody, err := json.Marshal(NatOut)
	if err != nil {
		Fatalln(err)
	}
	f, err := os.OpenFile("natout.json", os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0666)
	if err != nil {
		Fatalln(err)
	}
	count, err := f.Write(jbody)
	if count != len(jbody) || err != nil {
		Fatalln(err)
	}
	f.Write([]byte{'\n'})
	f.Close()
}

func GetOutlinkView(serverName string) (outlink map[string][]string) {
	outlink = make(map[string][]string)
	query := map[string]string{
		"NatName": serverName,
	}
	fields := []string{
		"OutlinkId", "OutlinkAddr", "NatlinkAddr",
		"NatserverId", "NatlinkGw", "NatlinkStatus"}
	result, err := models.GetAllOutlinkview(query, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}

	for _, record := range result {
		oln, addr, gw := "", "", ""
		status := 0
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "OutlinkAddr":
				oln = v.(string)
			case "NatlinkAddr":
				addr = v.(string)
			case "NatlinkGw":
				gw = v.(string)
			case "NatlinkStatus":
				status = v.(int)
			}
		}
		outlink[oln] = append(outlink[oln],
			fmt.Sprintf("src %s gw %s nat %d", addr, gw, status))
	}
	for k, v := range outlink {
		outlink[k] = dedup(v)
	}

	return
}

func GetNetlinkWLView() (dstAddrGp map[string][]string) {
	dstAddrGp = make(map[string][]string)
	fields := []string{
		"Ipnet", "Mask",
		"Isp"}
	result, err := models.GetAllNetLinkWLView(nil, nil, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}
	for _, record := range result {
		ipn, mask, dsn := "", "", ""
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "Ipnet":
				ipn = v.(string)
			case "Mask":
				mask = strconv.Itoa(int(v.(uint8)))
			case "Isp":
				dsn = v.(string)
			}
		}
		dstAddrGp[dsn] = append(dstAddrGp[dsn], ipn+"/"+mask)
	}
	return
}

func GetNetlinkView() (dstAddrGp map[string][]string) {
	dstAddrGp = make(map[string][]string)
	fields := []string{
		"Ipnet", "Mask",
		"Isp"}
	result, err := models.GetAllNetLinkView(nil, nil, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}
	for _, record := range result {
		ipn, mask, dsn := "", "", ""
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "Ipnet":
				ipn = v.(string)
			case "Mask":
				mask = strconv.Itoa(int(v.(uint8)))
			case "Isp":
				dsn = v.(string)
			}
		}
		dstAddrGp[dsn] = append(dstAddrGp[dsn], ipn+"/"+mask)
	}
	return
}

func GetClientSetWLView() (srcAddrGp map[string][]string) {
	srcAddrGp = make(map[string][]string)
	fields := []string{
		"Ipnet", "Mask",
		"ClientSetName"}
	result, err := models.GetAllClientSetWLView(nil, nil, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}
	for _, record := range result {
		ipn, mask, csn := "", "", ""
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "Ipnet":
				ipn = v.(string)
			case "Mask":
				mask = strconv.Itoa(int(v.(uint8)))
			case "ClientSetName":
				csn = v.(string)
			}
		}
		srcAddrGp[csn] = append(srcAddrGp[csn], ipn+"/"+mask)
	}
	return
}

func GetClientSetView() (srcAddrGp map[string][]string) {
	srcAddrGp = make(map[string][]string)
	fields := []string{
		"Ipnet", "Mask",
		"ClientSetName"}
	result, err := models.GetAllClientSetView(nil, nil, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}
	for _, record := range result {
		ipn, mask, csn := "", "", ""
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "Ipnet":
				ipn = v.(string)
			case "Mask":
				mask = strconv.Itoa(int(v.(uint8)))
			case "ClientSetName":
				csn = v.(string)
			}
		}
		srcAddrGp[csn] = append(srcAddrGp[csn], ipn+"/"+mask)
	}
	return
}

func GetSrcView() (rule []string) {
	query := map[string]string{
		"DomainPoolId": "1",
	}
	fields := []string{"ClientSetName", "RouteSetName"}
	result, err := models.GetAllSrcView(nil, query, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}
	for _, record := range result {
		csn, rsn := "", ""
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "ClientSetName":
				csn = v.(string)
			case "RouteSetName":
				rsn = v.(string)
			}
		}
		if csn == "default" && rsn == "default" {
			continue
		}
		rule = append(rule, fmt.Sprintf("%s via %s", csn, rsn))
	}
	return
}

func GetRouteView() (outtable map[string][]string) {
	outtable = make(map[string][]string)
	fields := []string{"RoutesetName",
		"NetlinksetName",
		"OutlinkAddr"}
	result, err := models.GetAllRouteView(nil, nil, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}
	for _, record := range result {
		nln, rsn, oln := "", "", ""
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "NetlinksetName":
				nln = v.(string)
			case "RoutesetName":
				rsn = v.(string)
			case "OutlinkAddr":
				oln = v.(string)
			}
		}
		if rsn == "default" {
			rsn = "main"
		}
		outtable[rsn] = append(outtable[rsn], fmt.Sprintf("%s via %s", nln, oln))
	}
	return
}

func GetIptable() (iptable map[string][]string) {
	iptable = make(map[string][]string)
	fields := []string{"NetlinkId", "Ipnet", "Mask"}
	result, err := models.GetAllIptable(nil, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}

	for _, record := range result {
		nlid, ipnet, mask := "", "", ""
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "NetlinkId":
				nlid = strconv.Itoa(v.(*models.Netlink).Id)
			case "Ipnet":
				ipnet = v.(string)
			case "Mask":
				mask = strconv.Itoa(int(v.(uint8)))
			}
		}
		iptable[nlid] = append(iptable[nlid], ipnet+"/"+mask)
	}
	return
}

func GetNetlink() (netlink map[string]string) {
	netlink = make(map[string]string)
	fields := []string{"Id", "Isp"}
	result, err := models.GetAllNetlink(nil, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}

	for _, record := range result {
		id, isp := "", ""
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "Id":
				id = strconv.Itoa(v.(int))
			case "Isp":
				isp = v.(string)
			}
		}
		netlink[id] = isp
	}
	return
}

func GetClientSet() (clientset map[string]string) {
	clientset = make(map[string]string)
	fields := []string{"Id", "Name"}
	result, err := models.GetAllClientset(nil, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}

	for _, record := range result {
		id, name := "", ""
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "Id":
				id = strconv.Itoa(v.(int))
			case "Name":
				name = v.(string)
			}
		}
		clientset[id] = name
	}
	return
}

func GetIpnet() (ipnet map[string][]string) {
	ipnet = make(map[string][]string)
	fields := []string{"ClientsetId", "Ipnet", "Mask"}
	result, err := models.GetAllIpnet(nil, fields, nil, nil, 0, rowLimit)
	if err != nil {
		Fatalln(err)
	}

	for _, record := range result {
		nlid, net, mask := "", "", ""
		for k, v := range record.(map[string]interface{}) {
			switch k {
			case "ClientsetId":
				nlid = strconv.Itoa(v.(*models.Clientset).Id)
			case "Ipnet":
				net = v.(string)
			case "Mask":
				mask = strconv.Itoa(int(v.(uint8)))
			}
		}
		ipnet[nlid] = append(ipnet[nlid], net+"/"+mask)
	}
	return
}

func NAT2DB() {
	loadStruct()
	insert()
}

func loadStruct() {
	file, err := os.Open("nat.json")
	if err != nil {
		Fatalln(err)
	}

	err = json.NewDecoder(file).Decode(&NatIn)
	if err != nil {
		Fatalln(err)
	}
}

func insert() {

	//Inser natserver
	serverId := InsertNatServer(*natserver)
	// insert outlink
	outlinkMap := make(map[string]int)
	for name, addrslice := range NatIn.OutLink {
		id := InsertOutlink(name)
		outlinkMap[name] = id
		for _, addr := range addrslice {
			addrlist := strings.Split(addr, " ")
			if len(addrlist) != 6 {
				Fatalln(addrlist)
			}
			InsertNatlink(serverId, id, addrlist[1], addrlist[3], addrlist[5])
		}
	}

	if *outlink_only {
		return
	}
	//Insert Client Set and Ipnet
	clientSetMap := make(map[string]int)
	for _, clientSetInfo := range NatIn.SrcRule {
		list := strings.Split(clientSetInfo, " ")
		if len(list) != 3 && list[1] != "via" {
			Fatalln("Format Error", clientSetInfo)
		}
		if !strings.HasPrefix(list[0], "adg") {
			clisetId := InsertClientSet(list[0])
			clientSetMap[list[0]] = clisetId
			InsertIpnet(list[0], clisetId)
		} else {
			srcAddrGroup[list[0]] = true
			iplist, ok := NatIn.AddrGroup[list[0]]
			if !ok {
				log.Fatalf("%s ipset not found\n", list[0])
			}
			clisetId := InsertClientSet(list[0])
			clientSetMap[list[0]] = clisetId
			for _, srcInfo := range iplist {
				InsertIpnet(srcInfo, clisetId)
			}
		}
	}

	//Insert dst Set and  Iptable
	netLinkMap := make(map[string]int)
	netlinksetMap := make(map[string]int)
	for addrName, addrIPList := range NatIn.AddrGroup {
		if srcAddrGroup[addrName] {
			continue
		}
		netlinkId := InsertNetlink(addrName)
		netLinkMap[addrName] = netlinkId
		netlinksetId := InsertNetlinkset(addrName)
		netlinksetMap[addrName] = netlinksetId
		InsertDomainlink(1, netlinkId, netlinksetId)
		for _, ipnet := range addrIPList {
			InsertIpTable(ipnet, netlinkId)
		}
	}

	// Insert  Outtable
	routeSetMap := make(map[string]int)

	for _, policy := range NatIn.OutTable["main"] {
		plist := strings.Split(policy, " ")
		if len(plist) != 3 {
			Fatalln(plist)
		}
		nsn := plist[0]
		if nsn == "default" {
			value, err := models.GetOutlinkById(1)
			if err != nil {
				Fatalln("Get default outlink", err)
			}
			value.Addr = plist[2]
			err = models.UpdateOutlinkById(value)
			if err != nil {
				Fatalln("Update default outlink", err)
			}
			InsertRoute(1, 1, outlinkMap[plist[2]])
		}
	}

	for _, policy := range NatIn.OutTable["main"] {
		plist := strings.Split(policy, " ")
		if len(plist) != 3 {
			Fatalln(plist)
		}
		nsn := plist[0]
		if nsn == "default" {
			continue
		}
		nlsId, ok := netlinksetMap[nsn]
		if !ok {
			nlId := InsertNetlink(nsn)
			netLinkMap[nsn] = nlId
			nlsId = InsertNetlinkset(nsn)
			netlinksetMap[nsn] = nlsId
		}
		InsertRoute(nlsId, 1, outlinkMap[plist[2]])
	}

	for name, policylist := range NatIn.OutTable {
		if name == "main" {
			continue
		}
		rsId := InsertRoutSet(name)
		routeSetMap[name] = rsId
		for _, policy := range policylist {
			plist := strings.Split(policy, " ")
			if len(plist) != 3 {
				Fatalln(plist)
			}
			nsn := plist[0]
			if nsn == "default" {
				InsertRoute(1, rsId, outlinkMap[plist[2]])
				continue
			}
			nlsId, ok := netlinksetMap[nsn]
			if !ok {
				nlId := InsertNetlink(nsn)
				netLinkMap[nsn] = nlId
				nlsId = InsertNetlinkset(nsn)
				netlinksetMap[nsn] = nlsId
			}
			InsertRoute(nlsId, rsId, outlinkMap[plist[2]])
		}
	}

	//Insert  SrcRule
	for _, rule := range NatIn.SrcRule {
		rulelist := strings.Split(rule, " ")
		if len(rulelist) != 3 {
			Fatalln(rulelist)
		}
		InsertViewer(clientSetMap[rulelist[0]],
			1, routeSetMap[rulelist[2]])
	}
}

func InsertViewer(clientsetId, domainpoolId, routesetId int) int {
	view := &models.Viewer{
		Enable:       1,
		PolicyId:     1,
		ClientsetId:  clientsetId,
		DomainPoolId: domainpoolId,
		RoutesetId:   routesetId,
	}

	id, err := models.AddViewer(view)
	if err != nil {
		Fatalln(err)
	}
	return int(id)
}

func InsertRoutSet(name string) int {
	rs := &models.Routeset{
		Name: name,
	}
	id, err := models.AddRouteset(rs)
	if err != nil {
		Fatalln(err)
	}
	return int(id)
}

func InsertRoute(netlnksId, routesetId, outlnkId int) int {
	route := &models.Route{
		Score:  50,
		Enable: 1,
		NetlinksetId: &models.Netlinkset{
			Id: netlnksId,
		},
		RoutesetId: &models.Routeset{
			Id: routesetId,
		},
		OutlinkId: &models.Outlink{
			Id: outlnkId,
		},
	}
	id, err := models.AddRoute(route)
	if err != nil {
		Fatalln(netlnksId, routesetId, outlnkId, err)
	}
	return int(id)
}

func InsertDomainlink(dmPoolId, netlinkId, netlinksetId int) int {
	dl := &models.Domainlink{
		DomainPoolId: dmPoolId,
		NetlinkId:    netlinkId,
		NetlinksetId: netlinksetId,
		Enable:       1,
	}
	id, err := models.AddDomainlink(dl)
	if err != nil {
		Fatalln(err)
	}
	return int(id)
}

func InsertNatlink(nsId, outlnkId int, addr, gw, status string) int {
	intstat, _ := strconv.Atoi(status)
	natlink := &models.Natlink{
		OutlinkId:   outlnkId,
		NatserverId: nsId,
		Addr:        addr,
		Gw:          gw,
		Status:      int8(intstat),
	}

	id, err := models.AddNatlink(natlink)
	if err != nil {
		Fatalln(err)
	}
	return int(id)
}

func InsertNatServer(name string) int {
	server := &models.Natserver{
		Name:   name,
		Enable: 1,
	}
	id, err := models.AddNatserver(server)
	if err != nil {
		Fatalln(err)
	}
	return int(id)
}

func InsertOutlink(name string) int {
	outlink := &models.Outlink{
		Enable: 1,
		Addr:   name,
		Name:   name,
	}
	id, err := models.AddOutlink(outlink)
	if err != nil {
		Fatalln(err)
	}
	return int(id)
}

func InsertNetlink(name string) int {
	netlink := &models.Netlink{
		Region: name,
		Isp:    name,
	}
	id, err := models.AddNetlink(netlink)
	if err != nil {
		Fatalln(err)
	}
	return int(id)
}

func InsertNetlinkset(name string) int {
	netlinks := &models.Netlinkset{
		Name: name,
	}
	id, err := models.AddNetlinkset(netlinks)
	if err != nil {
		Fatalln(err)
	}
	return int(id)
}

func InsertIpTable(dstInfo string, netlinkID int) {
	ipstart, ipend, ipnet, mask, err := CIDR(dstInfo)
	if err != nil {
		Fatalln(err)
	}
	tmpIptable := &models.Iptable{
		IpStart: ipstart,
		IpEnd:   ipend,
		Ipnet:   ipnet,
		Mask:    mask,
		NetlinkId: &models.Netlink{
			Id: netlinkID,
		},
	}
	_, err = models.AddIptable(tmpIptable)
	if err != nil {
		log.Println("Error", err)
	}
}

func InsertClientSet(name string) int {
	clientset := &models.Clientset{
		Name: name,
		Info: name,
	}
	id, err := models.AddClientset(clientset)
	if err != nil {
		Fatalln(err)
	}
	return int(id)
}

func InsertIpnet(srcInfo string, clientSetID int) {
	ipstart, ipend, ipnet, mask, err := CIDR(srcInfo)
	if err != nil {
		Fatalln(err)
	}
	tmpIpnet := &models.Ipnet{
		IpStart: ipstart,
		IpEnd:   ipend,
		Ipnet:   ipnet,
		Mask:    mask,
		ClientsetId: &models.Clientset{
			Id: clientSetID,
		},
	}
	_, err = models.AddIpnet(tmpIpnet)
	if err != nil {
		Fatalln(err)
	}
}

func CIDR(s string) (ipstart, ipend, ipnet string, mask uint8, err error) {
	list := strings.Split(s, "/")
	if len(list) != 2 {
		err = fmt.Errorf("format error: %s", s)
		return
	}

	ip := net.ParseIP(list[0])
	maskU64, err := strconv.ParseUint(list[1], 10, 8)
	if err != nil || maskU64 > 32 {
		err = fmt.Errorf("mask error: %s", list[1])
		return
	}
	mask = uint8(maskU64)
	if ip2int(ip)&(1<<(32-mask)-1) != 0 {
		err = fmt.Errorf("mask error2: %s", list[1])
		return
	}
	intStart := ip2int(ip) &^ (1<<(32-mask) - 1)
	ipstart = int2ip(intStart).String()
	ipend = int2ip(intStart | (1<<(32-mask) - 1)).String()
	ipnet = ipstart
	return
}

func ip2int(ip net.IP) uint32 {
	return binary.BigEndian.Uint32(ip[12:16])
}

func int2ip(u uint32) net.IP {
	ip := make(net.IP, 4)
	binary.BigEndian.PutUint32(ip, u)
	return ip
}

func Fatalln(v ...interface{}) {
	_, file, line, _ := runtime.Caller(1)
	log.Fatalln(file, line, v)
}

func dedup(slice []string) (uniq []string) {
	m := make(map[string]bool, len(slice))
	uniq = make([]string, 0, len(slice))
	for _, v := range slice {
		if m[v] {
			continue
		}
		m[v] = true
		uniq = append(uniq, v)
	}
	return
}
