clear all
cd "E:\Github\own\COVID-19_share"

**********************
*******收集数据*******
**********************

local URL = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"

forvalues month = 1/4 ///
{
	forvalues day = 1/31 ///
	{
		local month = string(`month', "%02.0f")
		local day = string(`day', "%02.0f") 
		// Note that the string() function adds leading zeros for month and day where necessary.
		local year = "2020"
		local today = "`month'-`day'-`year'"
		local FileName = "`URL'`today'.csv"
		clear
		
		capture import delimited "`FileName'"
		
		capture confirm variable confirmed
		if _rc == 0 ///
		{
			
			capture rename ïprovincestate provincestate
			capture label variable provincestate "Province/State"
			*I learned through trial and error that the variable provincestate is imported as ïprovincestate in some files and provincestate in others. 
			*We want to import many files, and we don’t want to have to look through each file manually. 
			*So let’s use confirm to check each file for a variable named ïprovincestate.

			capture rename province_state provincestate
			capture rename country_region countryregion
			capture rename last_update lastupdate
			capture rename lat latitude
			capture rename long longitude
			*We have variables with similar names, such as provincestate and province_state, countryregion and country_region, and so forth. 
			*A simple alternative is to use capture rename to change the variable names where necessary in the raw data files.
			
			generate tempdate = "`today'"
			capture save "`today'", replace
			display "`today'.dta has been downloaded"
		}		
	}
}

clear 

forvalues month = 1/4 ///
{
	forvalues day = 1/31 ///
	{
		local month = string(`month', "%02.0f")
		local day = string(`day', "%02.0f")
		local year = "2020"
		local today = "`month'-`day'-`year'"
		capture append using "`today'"
		*Our local directory now contains a collection of Stata data files that we wish to combine into a single file. 
		*We can do this using append. Another loop would allow us to automate this process. 
		*Note that I have used the capture trick before append because we don’t have a file for every day of 2020.
	}
}

save covid19_raw,replace

**********************

**********************
*******处理数据*******
**********************

*The date data saved in tempdate are stored consistently, but the data are still stored as a string. 
*We can use the date() function to convert tempdate to a number. The date(s1,s2) function returns a number based on two arguments, s1 and s2. The argument s1 is the string we wish to act upon and the argument s2 is the order of the day, month, and year in s1. Our tempdate variable is stored with the month first, the day second, and the year third. So we can type s2 as MDY, which indicates that Month is followed by Day, which is followed by Year. We can use the date() function below to convert the string date 03-23-2020 to a number.

display date("03-23-2020", "MDY")

*The date() function returned the number 21997. That doesn’t look like a date to you and me, but it indicates the number of days since January 1, 1960. 
*The example below shows that 01-01-1960 is the 0 for our time data.

generate date = date(tempdate, "MDY")

list lastupdate tempdate date in -5/l
*Let’s use date() to generate a new variable named date.

format date %tdNN/DD/CCYY

list lastupdate tempdate date in -5/l
*Next, we can use format to display the numbers in date in a way that looks familiar to you and me

save covid19_date, replace
*Let’s save this dataset so that we don’t have to download the raw data for each of the following examples.

list in -5/l

**********************

**********************
*********画图*********
**********************

*Let’s create a time-series plot for the number of confirmed cases for all countries combined.

global  Global_Confirmed             					0

if $Global_Confirmed == 1 ///
{
	use covid19_date, clear

	collapse (sum) confirmed deaths recovered, by(date)

	describe
	*We can describe our new dataset and see that it contains the variables date, confirmed, deaths, and recovered. 
	*The variable labels tell us that confirmed, deaths, and recovered are the sum of each variable for each value of date.

	tsset date, daily
	*Now, we can use tsset to specify the structure of our time-series data, which will allow us to use Stata’s time-series features.

	generate newcases = D.confirmed
	*The time-series operator D.varname calculates the difference between an observation and the preceding observation in varname.

	tsline confirmed, title(Global Confirmed COVID-19 Cases) ///
	ylabel(0 100000 1000000 2000000, angle(horizontal))
	* Time-series line plots

}

*Create time-series data for multiple countries

global  Countries_Confirmed             					0

if $Countries_Confirmed == 1 ///
{
	use covid19_date, clear

	tab countryregion
	*Two categories include China: “China” and “Mainland China”. 
	*Closer inspection of the raw data shows that the name was changed from “Mainland China” to “China” after March 12, 2020. 
	*I am going to combine the data by renaming the category “Mainland China”.
	
	replace countryregion = "China" if countryregion=="Mainland China"
	keep if inlist(countryregion, "China", "US", "Italy")
	* I am going to keep the observations from China, Italy, and the United States using inlist().
	
	keep if inlist(countryregion, "China", "US", "Italy")
	
	collapse (sum) confirmed deaths recovered, by(date countryregion)
	
	list date countryregion confirmed deaths recovered ///
    in -9/l, sepby(date) abbreviate(13)
	
	*The variable countryregion is stored as a string variable, 
	*and I happen to know that we will need a numeric variable for some of the commands we will use shortly.
	
	encode countryregion, gen(country)
	*The variables countryregion and country look the same when we list the data. 
	*But country is a numeric variable with value labels that were created by encode. You can type label list to view the categories of country.
	
	list date countryregion country  ///
    in -9/l, sepby(date) abbreviate(13)
	
	tsset country date, daily
	
	save covid19_long,replace
	
	*You might prefer to have your data in wide format so that the data for each country are side by side. 
	*We can use reshape to do this. Let’s keep only the data we will use before we use reshape.
	
	keep date country confirmed deaths recovered

	reshape wide confirmed deaths recovered, i(date) j(country)
	
	*The data for confirmed cases in China, Italy, and the United States in our original dataset were placed, respectively, in variables confirmed1, confirmed2, and confirmed3 in our new dataset. How do I know this?
	*Recall that the data for country were stored in a labeled, numeric variable. China was saved as 1, Italy was saved as 2, and the United States was stored as 3.
	
	list date confirmed1 confirmed2 confirmed3  ///
    in -5/l, abbreviate(13)
	
	*These variable names could be confusing, so let’s rename and label our variables to avoid confusion. 
	*I will use the suffix _c to indicate “confirmed cases”, _d to indicate “deaths”, and _r to “indicate recovered”.
	*The variable labels will make this naming convention explicit.
	
	rename confirmed1 china_c
	rename deaths1 china_d
	rename recovered1 china_r
	label var china_c "China cases"
	label var china_d "China deaths"
	label var china_r "China recovered"

	rename confirmed2 italy_c
	rename deaths2 italy_d
	rename recovered2 italy_r
	label var italy_c "Italy cases"
	label var italy_d "Italy deaths"
	label var italy_r "Italy recovered"


	rename confirmed3 usa_c
	rename deaths3 usa_d
	rename recovered3 usa_r
	label var usa_c "USA cases"
	label var usa_d "USA deaths"
	label var usa_r "USA recovered"
	
	*We could plot our data to compare the number of confirmed cases for China, Italy, and the US.
	twoway (line china_c date,lcolor(green)) ///
    (line italy_c date,lcolor(blue)) ///
    (line usa_c date,lcolor(red))   ///
    , title(Confirmed COVID-19 Cases) ///
	ylabel(0 100000 200000 500000, angle(horizontal))
	
}

* 绘制中国当前确诊人数
global  china_total_cases             					1
if $china_total_cases == 1 ///
{
	use covid19_date, clear

	*china_full_map_db.dta: 中国地图数据库文件；
	*china_full_map_coord.dta：中国地图坐标系文件；
	*china_full_map_label.dta：中国地图省份标签文件；
	*china_full_map_line.dta：中国地图框架线文件。

	replace provincestate = "Taiwan" if countryregion == "Taiwan*"

	replace countryregion = "China" if countryregion=="Mainland China" || countryregion == "Taiwan*" || countryregion == "Taiwan"
	keep if inlist(countryregion, "China")

	keep if date == date("04-18-2020", "MDY")

	rename provincestate prov

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

	merge 1:1 NAME using china_full_map_db
	drop _merge

	local times = "截止 2020 年 4 月 18 号"
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
	}

* 绘制各省当前确诊人数
global  province_total_cases             					1
if $province_total_cases == 1 ///
{
	use covid19_date, clear

	replace provincestate = "Taiwan" if countryregion == "Taiwan*"

	replace countryregion = "China" if countryregion=="Mainland China" || countryregion == "Taiwan*" || countryregion == "Taiwan"
	keep if inlist(countryregion, "China")

	keep date provincestate confirmed 
	replace confirmed = 0 if confirmed == .

	replace provincestate = subinstr(provincestate, " ", "_", .)
	tab provincestate

	sort date

	capture noisily reshape wide confirmed , i(date) j(provincestate) string
	reshape error
	display date("03/11/2020", "MDY")
	display date("03/12/2020", "MDY")

	drop if date == 21985 & provincestate == "Gansu" & confirmed == 0
	drop if date == 21986 & provincestate == "Gansu" & confirmed == 0
	drop if date == 21985 & provincestate == "Hebei" & confirmed == 0	
	drop if date == 21986 & provincestate == "Hebei" & confirmed == 0	

	spread provincestate confirmed

	twoway connect Anhui Guangdong Shanxi Zhejiang date, ///
	xtitle("日期", size(*0.8)) /// 
	ytitle("确诊总人数", size(*0.8)) ///
	title("中国各省确诊总人数变化", size(*1.1)) ///
	subtitle("安徽、广东、山西和浙江四个省") ///
	caption("数据来源：约翰·霍普金斯大学", size(*0.8)) xla(21936(16)22023) ///
	xscale(range(21936 22023) extend) /// /// display date("01/22/2020", "MDY") 和 display date("04/18/2020", "MDY")得知
	legend(order(1 "安徽" 2 "广东" 3 "山西" 4 "浙江")) ///
	lc("102 194 165" "252 141 98" "141 160 203" "231 138 195") ///
	mc("102 194 165" "252 141 98" "141 160 203" "231 138 195")


}

**********************

clear



