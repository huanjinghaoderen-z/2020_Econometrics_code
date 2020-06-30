cd "C:\Users\jiacheng pan\Desktop\使用 Stata 分析新冠肺炎疫情数据"
/* 读取整理数据 */
* 确诊数据
import delimited using "time_series_covid19_confirmed_global.csv", clear varnames(nonames) encoding(utf8)

* 将第一行的 / 替换成 _
foreach i of varlist _all{
	replace `i' = subinstr(`i', "/", "_", .)
}

* 将变量名重命名为第一行的观测值
* nrow 的安装
*ssc install nrow
nrow 1

* 把宽数据转换成长数据
* gather 的安装：
*net install tidy.pkg, from("https://czxa.top/pkg/tidy.ado")
gather _1_22_20 - _3_28_20

* 先分析中国的数据
keep if inlist(Country_Region, "China", "Taiwan*")
replace Province_State = "Taiwan" if Country_Region == "Taiwan*"
drop Country_Region
ren Province_State prov
ren Lat lat
ren Long lon
ren variable var
ren value confirmed

* 把所有变量的显示格式调整为 %10s
foreach i of varlist _all{
	format `i' %10s
}

* 把可以转换成数值型的变量转换成数值型
destring, replace

* 将 var 转为日期
replace var = subinstr(var, "_20", "_2020", .)
replace var = subinstr(var, "_2020_2020", "_20_2020", .)
gen date = date(var, "MDY")
drop var
format date %tdCY-N-D
order prov date
save confirmed, replace

* 同样的方式处理另外两个数据
foreach t in "deaths" "recovered" {
	import delimited using "time_series_covid19_`t'_global.csv", clear varnames(nonames) encoding(utf8)
	foreach i of varlist _all{
		replace `i' = subinstr(`i', "/", "_", .)
	}
	nrow 1
	gather _1_22_20 - _3_28_20
	keep if inlist(Country_Region, "China", "Taiwan*")
	replace Province_State = "Taiwan" if Country_Region == "Taiwan*"
	ren Province_State prov
	ren Lat lat
	ren Long lon
	ren variable var
	ren value `t'
	destring, replace
	replace var = subinstr(var, "_20", "_2020", .)
	replace var = subinstr(var, "_2020_2020", "_20_2020", .)
	gen date = date(var, "MDY")
	drop var Country_Region
	format date %tdCY-N-D
	save `t', replace
}

* 合并三个数据
use confirmed, clear
merge 1:1 prov date using deaths
drop _m
merge 1:1 prov date using recovered
drop _m

save china_covid, replace

/* 开始分析数据 */
use china_covid, clear
* 计算每日新增
* 设定面板数据
encode prov, gen(prov_id)
order prov_id date
xtset prov_id date
gen new_confirmed = confirmed - l.confirmed
gen new_deaths = deaths - l.deaths
gen new_recovered = recovered - l.recovered

* 删除第一天的
drop if missing(new_confirmed)
save china_covid, replace

* 可视化分析
* 绘制各个省的现存确诊人数增长曲线图
use china_covid, clear
gen current_confirmed = confirmed - deaths - recovered
replace current_confirmed = 0 if current_confirmed < 0
keep prov date current_confirmed
drop if missing(current_confirmed)
replace prov = subinstr(prov, " ", "_", .)
spread prov current_confirmed
drop Hubei
tw conn Anhui - Zhejiang date, xti("日期", size(*0.8)) /// 
	yti("现存确诊人数", size(*0.8)) ///
	ti("中国各省现存确诊人数变化（去除湖北）", size(*1.3)) ///
	subti("") caption("数据来源：约翰·霍普金斯大学| 绘制：TidyFriday", size(*0.8))
gr export img4.png, replace

* 这样太多了，我们选择几个省观察吧
tw conn Anhui Guangdong Shanxi Zhejiang date, xti("日期", size(*0.8)) /// 
	yti("现存确诊人数", size(*0.8)) ///
	ti("中国各省现存确诊人数变化", size(*1.3)) ///
	subti("安徽、广东、山西和浙江四个省") caption("数据来源：约翰·霍普金斯大学| 绘制：TidyFriday", size(*0.8)) xla(21937(16)22000) ///
	xsc(range(21937 22000) extend) ///
	leg(order(1 "安徽" 2 "广东" 3 "山西" 4 "浙江") pos(1) ring(0)) ///
	lc("102 194 165" "252 141 98" "141 160 203" "231 138 195") ///
	mc("102 194 165" "252 141 98" "141 160 203" "231 138 195")
gr export img5.png, replace

* 面板数据的分面图
use china_covid, clear
gen current_confirmed = confirmed - deaths - recovered
replace current_confirmed = 0 if current_confirmed < 0
xtline current_confirmed, xti(日期) yti(现存确诊人数) byopts(note("数据来源：约翰·霍普金斯大学| 绘制：TidyFriday") ti(各省现存确诊人数变化) r)
gr export img6.png, replace

xtline current_confirmed, overlay xti(日期) yti(现存确诊人数) ti(各省现存确诊人数变化)
gr export img7.png, replace

* 如何自己绘制分面图
tw line current_confirmed date, by(prov, ti(各省现存确诊人数变化) note("数据来源：约翰·霍普金斯大学| 绘制：TidyFriday") r) xti(日期) yti(现存确诊人数)

* 计算中国每天的总数
use china_covid, clear
collapse (sum) confirmed (sum) deaths (sum) recovered, by(date)
* 计算累积量
gen base = 0
gen deaths_recovered = deaths + recovered
* 绘图
tw ///
rarea recovered base date, fc("180 209 132") ///
	c("180 209 132") fintensity(inten80) lw(vvthin) || ///
rarea deaths_recovered recovered date, fc("122 118 123") ///
	c("122 118 123") fintensity(inten80) lw(vvthin) || ///
rarea confirmed deaths_recovered date, fc("95 144 161") ///
	c("95 144 161") fintensity(inten80) lw(vvthin) ||, ///
	leg(order(3 "现存确诊" 2 "死亡" 1 "治愈") pos(11) ring(0)) ///
	title("新冠肺炎疫情在中国的发展状况", size(*1.5) ///
		justification(left) bexpand) ///
	subtitle("这幅图展示了中国新冠肺炎的确诊人数、治愈人数和死亡人数的发展趋势，数据来源" "于约翰霍普金斯大学。", ///
		justification(left) bexpand) ///
	caption("数据来源：约翰霍普金斯大学 | 绘制：TidyFriday", ///
		size(*0.8)) ///
	xti("") xla(21937(8)22000) ///
	xsc(range(21937 22000) extend) ///
	graphr(margin(medlarge)) ///
	text(20000 21984 "治愈", color(black) size(*1.2)) ///
	text(63000 21983 "死亡", color(black) size(*1.2)) ///
	text(70000 21978 "现存确诊", color(black) size(*1.2)) || ///
pci 80000 21957 0 21957, lp(dash) text(56000 21952 "我国改变了" "确诊的标准", color(black) size(*0.8) justification(right) bexpand)
gr export img8.png, replace

* 当前确诊人数与每日新增确诊人数
use china_covid, clear
collapse (sum) confirmed (sum) deaths (sum) recovered, by(date)
tsset date
gen new_confirmed = confirmed - l.confirmed
tw ///
lpolyci new_confirmed date, bw(3) || ///
sc new_confirmed date, ms(circle) ||, ///
	leg(off) xlab(, format(%tdCY-N-D)) xla(21937(16)22000) ///
	xsc(range(21937 22000) extend) ///
	ti("每日新增确诊数", size(*1.2)) ///
	yti("人数") name(a, replace) nodraw

gen current_confirmed = confirmed - deaths - recovered
replace current_confirmed = 0 if current_confirmed < 0
tw ///
lpolyci current_confirmed date, bw(3) || ///
sc current_confirmed date, ms(circle) ||, ///
	leg(off) xlab(, format(%tdCY-N-D)) xla(21937(16)22000) ///
	xsc(range(21937 22000) extend) ///
	ti("现存确诊数", size(*1.2)) ///
	yti("人数") name(b, replace) nodraw

gr combine a b, caption("数据来源：约翰霍普金斯大学 | 绘制：TidyFriday", size(*0.8)) xsize(20) ysize(12) ///
	graphr(margin(medlarge))
gr export img9.png, replace

* 死亡和治愈病例数量
use china_covid, clear
collapse (sum) confirmed (sum) deaths (sum) recovered, by(date)
tsset date
tw ///
lpolyci recovered date, bw(3) || ///
sc recovered date, ms(circle) ||, ///
	leg(off) xlab(, format(%tdCY-N-D)) xla(21937(16)22000) ///
	xsc(range(21937 22000) extend) ///
	ti("累计治愈人数", size(*1.2)) ///
	yti("人数") name(a, replace) nodraw

tw ///
lpolyci deaths date, bw(3) || ///
sc deaths date, ms(circle) ||, ///
	leg(off) xlab(, format(%tdCY-N-D)) xla(21937(16)22000) ///
	xsc(range(21937 22000) extend) ///
	ti("累计死亡病例数", size(*1.2)) ///
	yti("人数") name(b, replace) nodraw

* 每日新增治愈
gen new_recovered = recovered - l.recovered
tw ///
lpolyci new_recovered date, bw(3) || ///
sc new_recovered date, ms(circle) ||, ///
	leg(off) xlab(, format(%tdCY-N-D)) xla(21937(16)22000) ///
	xsc(range(21937 22000) extend) ///
	ti("每日新增治愈人数", size(*1.2)) ///
	yti("人数") name(c, replace) nodraw

* 每日新增死亡
gen new_deaths = deaths - l.deaths
tw ///
lpolyci new_deaths date, bw(3) || ///
sc new_deaths date, ms(circle) ||, ///
	leg(off) xlab(, format(%tdCY-N-D)) xla(21937(16)22000) ///
	xsc(range(21937 22000) extend) ///
	ti("每日新增", size(*1.2)) ///
	yti("人数") name(d, replace) nodraw

gr combine a b c d, r(2) caption("数据来源：约翰霍普金斯大学 | 绘制：TidyFriday", size(*0.8)) xsize(20) ysize(12) ///
	graphr(margin(medlarge))
gr export img10.png, replace

* 死亡率
* 当日死亡率
gen daily_death_rate = new_deaths / (new_deaths +  new_recovered)
* 死亡率下限
gen death_rate_lower = deaths / confirmed
* 死亡率上限
gen death_rate_upper = deaths / (recovered + deaths)
tw ///
rarea death_rate_upper death_rate_lower date, ///
	fc(gs10) lc(gs10) || ///
line daily_death_rate date, lp(solid) lc(44 62 80) ||, ///
	yti("死亡率") yla(, format(%6.2f)) ///
	xti("") xla(21937(16)22000) ///
	xsc(range(21937 22000) extend) ///
	ti("新冠肺炎死亡率（中国）", size(*1.5)) ///
	subti("时间范围：2020年1月23日——2020年3月28日") ///
	leg(order(1 "死亡率估计区间" 2 "当日死亡率") pos(2) ring(0)) ///
	caption("数据来源：约翰霍普金斯大学 | 绘制：TidyFriday", size(*0.8)) ///
	graphr(margin(medlarge))
gr export img11.png, replace

* 地理分布（2020-03-28）
* 绘制九段线小框格的数据
use china_full_map_line.dta, clear
keep if _ID >= 35
save mybox_coord, replace

use china_covid, clear
keep if date == date("2020-03-28", "YMD")
keep prov confirmed deaths recovered
gen NAME = "安徽"
replace NAME = "北京" if prov == "Beijing"
replace NAME = "重庆" if prov == "Chongqing"
replace NAME = "福建" if prov == "Fujian"
replace NAME = "甘肃" if prov == "Gansu"
replace NAME = "广东" if prov == "Guangdong"
replace NAME = "广西" if prov == "Guangxi"
replace NAME = "贵州" if prov == "Guizhou"
replace NAME = "海南" if prov == "Hainan"
replace NAME = "河北" if prov == "Hebei"
replace NAME = "黑龙江" if prov == "Heilongjiang"
replace NAME = "河南" if prov == "Henan"
replace NAME = "香港" if prov == "Hong Kong"
replace NAME = "湖北" if prov == "Hubei"
replace NAME = "湖南" if prov == "Hunan"
replace NAME = "内蒙古" if prov == "Inner Mongolia"
replace NAME = "江苏" if prov == "Jiangsu"
replace NAME = "江西" if prov == "Jiangxi"
replace NAME = "吉林" if prov == "Jilin"
replace NAME = "辽宁" if prov == "Liaoning"
replace NAME = "澳门" if prov == "Macau"
replace NAME = "宁夏" if prov == "Ningxia"
replace NAME = "青海" if prov == "Qinghai"
replace NAME = "陕西" if prov == "Shaanxi"
replace NAME = "山东" if prov == "Shandong"
replace NAME = "上海" if prov == "Shanghai"
replace NAME = "山西" if prov == "Shanxi"
replace NAME = "四川" if prov == "Sichuan"
replace NAME = "台湾" if prov == "Taiwan"
replace NAME = "天津" if prov == "Tianjin"
replace NAME = "西藏" if prov == "Tibet"
replace NAME = "新疆" if prov == "Xinjiang"
replace NAME = "云南" if prov == "Yunnan"
replace NAME = "浙江" if prov == "Zhejiang"
save covid_with_cnname, replace
merge 1:1 NAME using china_full_map_db
local times = "截止 2020 年 3 月 28 号"
*ssc install spmap, replace
spmap confirmed using china_full_map_coord, id(ID) ///
	fcolor("255 249 247" "254 229 217" "252 174 145" "251 106 74" "222 45 38" ///
		"165 15 21") ///
	ocolor("white" ...) ///
	clmethod(custom) clbreaks(0 0.9 9.9 99 999 9999 99999) /// 
	ti(新型冠状病毒肺炎总确诊病例分布, size(*1.2) color(black)) ///
	graphr(margin(medium)) ///
	subti(`times', color(black)) ///
	osize(vvthin ...) ///
	legend(size(*1.3) ///
		order(2 "无" 3 "1~9 人" 4 "10~99 人" 5 "100~999 人" 6 "1000~9999人" 7 ">= 10000 人") ///
		ti(确诊, size(*0.5) pos(11) color(black)) color(black)) ///
	label(data(china_full_map_label) x(X) y(Y) l(NAME) color(black) size(*0.8)) ///
	line(data(mybox_coord) size(*0.3 ...) color(black))
gr export img12.png, replace

* 现存确诊人数
gen current_confirmed = confirmed - deaths - recovered
replace current_confirmed = 0 if current_confirmed < 0
local times = "截止 2020 年 3 月 28 号"
grmap current_confirmed using china_full_map_coord, id(ID) ///
	fcolor("255 249 247" "252 174 145" "251 106 74" "222 45 38" ///
		"165 15 21") ///
	ocolor("white" ...) ///
	clmethod(custom) clbreaks(0 0.9 9.9 99 999 9999) /// 
	ti(新型冠状病毒肺炎现存确诊病例分布, size(*1.2) color(black)) ///
	graphr(margin(medium)) ///
	subti(`times', color(black)) ///
	osize(vvthin ...) ///
	legend(size(*1.3) ///
		order(2 "无" 3 "1~9 人" 4 "10~99 人" 5 "100~999 人" 6 ">1000 人") ///
		ti(确诊, size(*0.5) pos(11) color(black)) color(black)) ///
	label(data(china_full_map_label) x(X) y(Y) l(NAME) color(black) size(*0.8)) ///
	line(data(china_full_map_line) size(*0.2 ...) color(black))
gr export img13.png, replace

* 地图 + 饼图
use china_full_map_label, clear
merge 1:1 NAME using covid_with_cnname
gen current_confirmed = confirmed - deaths - recovered
replace current_confirmed = 0 if current_confirmed < 0
drop if missing(confirmed)
save piedata, replace

use covid_with_cnname, clear
merge 1:1 NAME using china_full_map_db
local times = "截止 2020 年 3 月 28 号"
grmap confirmed using china_full_map_coord, id(ID) ///
	fcolor("255 249 247" "254 229 217" "252 174 145" "251 106 74" "222 45 38" "165 15 21" "122 118 123" "180 209 132") ///
	ocolor("white" ...) ///
	clmethod(custom) clbreaks(0 0.9 9.9 99 999 9999 99999 999999 9999999) /// 
	ti(新型冠状病毒肺炎总确诊病例分布, size(*1.2) color(black)) ///
	graphr(margin(medium)) ///
	subti(`times', color(black)) ///
	osize(vvthin ...) ///
	legend(size(*1.3) ///
		order(2 "无" 3 "1~9 人" 4 "10~99 人" 5 "100~999 人" 6 "1000~9999人" 7 ">= 10000 人" 9 "已治愈" 8 "死亡") ///
		ti(确诊, size(*0.5) pos(11) color(black)) color(black)) ///
	label(data(china_full_map_label) select(keep if ID == 36) x(X) y(Y) l(NAME) color(black) size(*0.8)) ///
	line(data(mybox_coord) size(*0.3 ...) color(black)) ///
	diagram(data(piedata) x(X) y(Y) v(deaths recovered) ///
		type(pie) legenda(on) os(vvthin) size(1.5) fc("122 118 123" "180 209 132"))
gr export img14.png, replace
