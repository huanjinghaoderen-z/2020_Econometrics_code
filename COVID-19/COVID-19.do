cd "...\COVID-19" //改为本地路径

**********************
*******收集数据*******
**********************

local URL = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"

forvalues month = 1/12 ///
{
	forvalues day = 1/31 ///
	{
		local month = string(`month', "%02.0f")
		local day = string(`day', "%02.0f") // Note that the string() function adds leading zeros for month and day where necessary.
		local year = "2020"
		local today = "`month'-`day'-`year'"
		local FileName = "`URL'`today'.csv"
		clear
		
		capture import delimited "`FileName'"
		
		capture confirm variable confirmed
		if _rc == 0 ///
		{
			capture confirm variable ïprovincestate
			if _rc == 0 ///
			{
				rename ïprovincestate provincestate
				label variable provincestate "Province/State"
			}
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
		}		
	}
}

clear 

forvalues month = 1/12 ///
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

generate date = date(tempdate, "MDY")

list lastupdate tempdate date in -5/l
*Let’s use date() to generate a new variable named date.

format date %tdNN/DD/CCYY

list lastupdate tempdate date in -5/l
*Next, we can use format to display the numbers in date in a way that looks familiar to you and me

save covid19_date, replace
*Let’s save this dataset so that we don’t have to download the raw data for each of the following examples.

**********************
