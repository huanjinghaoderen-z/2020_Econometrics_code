/* 
***************************************************************************
	Name of file: 	伍德里奇第五版程序.do
		
	Files Used:		WAGE1
					MEAP01
					JTRAIN2
					WAGE2
					MEAP93
					CEOSAL2
					DISCRIM
					BWGHT
					HPRICE1
					GPA3
					LAWSCH85
					FERTIL2
					BEAUTY

				
				
*************************************************************************** 
*/

set more off // It can be useful to include the "set more off" command at the start of a do-file so that output scrolls continuously rather than pausing after each page of output.

global path_Wooldridge "E:\Github\own\2020年春计量经济学助教\伍德里奇第五版程序及答案"  // Add your local directory here

global outpath_Wooldridge "${path_Wooldridge}\Results"
cap mkdir "$outpath_Wooldridge"

global dta_path_Wooldridge "${path_Wooldridge}\data"

cd "${dta_path_Wooldridge}"

*   ===============================
*	Choose sections to run
*   ===============================

// Set to 1 if want section run, 0 otherwise

global  delimit             						1
global	chapter_1_C1							1
global	chapter_2_12							1
global	chapter_4_2							1 
global	chapter_1_C3							1
global	chapter_1_C4							1
global	chapter_2_C4							1
global	chapter_2_C6							1
global	chapter_3_C3							1
global	chapter_3_C8							1
global	chapter_7_1		    					1
global	chapter_7_6		    					1
global	chapter_7_C12		    					1
global	chapter_4_9		    					1
global	chapter_4_linear_restrictions		    			1
global	chapter_7_Chow_statistic		    			1
global	chapter_5_3		    					1
global	chapter_4_C2		    					1
global	chapter_4_C5		    					1
global	chapter_7_C3		    					1
global	chapter_7_C4		    					1
global	chapter_7_C6		    					1
global	chapter_8_4_8_5		    					1
global	chapter_8_7		    					1
global	chapter_9_2		    					1

*   ===============================
/*
capture log close
log using "$outpath_Wooldridge\Analysis ($S_DATE)", replace
*/
*   ===============================

if $delimit /// // Use three slashes "///" to allow a command to span more than one line
{
	
	* For long commands, you can alternatively use the command "#delimit" command. This changes the delimiter from the Stata default, which is a carriage return (i.e., end-of-line), to a semicolon. This also permits more than one command on a single line.	
	
	* The following code changes the delimiter from the default to a semicolon and back to the default:
	
	use auto,clear
	
	#delimit ;
	
	summarize weight price displ headroom rep78 length turn gear_ratio
	, detail ;
	
	#delimit cr
	
	summarize weight price displ headroom rep78 length turn gear_ratio, detail
}

if $chapter_1_C1 ///
{
	use "WAGE1.dta", clear // where the "clear" option is added to remove the current dataset from memory 
	
	*第一小题
		sum educ
		
		*The Stata commands that analyze the data but do not estimate parameters are rclass commands. All r-class commands save their results in "r()". The contents of "r()" vary with the command and are listed by typing "return list".
		
		return list
	
	*第二小题
		mean wage
		
	*第四小题
		tab female
		
	#delimit cr
		
		count if female == 1
		count if female != 1
		
}

if $chapter_2_12 ///
{
	use "MEAP93.dta", clear
	
	reg math10 lnchprg
	
}

if $chapter_4_2 ///
{
    use "MEAP93.dta", clear
	
	reg math10 totcomp staff enroll
	
	*Critical values for t at level 0.05
	
	scalar alpha = 0.05
	scalar c_t404 = invttail(404,alpha)
	scalar c_z = -invnormal(alpha)
	
	display "Critical values" "t(404) = " c_t404
	display "Critical values" "standard normal distribution = " c_z
	
	reg math10 ltotcomp lstaff lenroll
	
}

if $chapter_1_C3 ///
{
	
	use "MEAP01.dta", clear
	
	*第一小题
		sum math4
		
	*第二小题
		tab math4
	
	*第三小题
		tab math4 if math4 == 50
		
	*第四小题
		sum math4 read4
	
	*第五小题
		cor math4 read4
		
	*第六小题
		sum exppp
		
}

if $chapter_1_C4 ///
{
	
	use "JTRAIN2.dta", clear
	
	*第一小题
		tab train
		
	*第二小题、第三小题
		mean re78, over(train)
		mean unem78, over(train)
		
	*第四小题
		sdtest re78, by(train)
		ttest re78, by(train) unequal 
		// 我们可以拒绝认为得到工作培训者的工资均值和没有得到工作培训者的工资均值相同
		
		sdtest unem78, by(train)
		ttest unem78, by(train) unequal 
		// 我们可以拒绝认为得到工作培训者的失业比例均值和没有得到工作培训者的失业比例均值相同
			
}

if $chapter_2_C4 ///
{
    use "WAGE2.dta", clear
	
    *第一小题
		sum wage IQ
		
	*第二小题
		reg wage IQ
		// IQ提高15个单位时，wage预期增加预期增加8.303*15=124.545；
		// IQ只能解释约9.55%的工资变异
		
	*第三小题
		g log_wage=log(wage)
		reg log_wage IQ
		// 所以如果IQ提高15个单位，wage大约提高0.0088*15*100%=13.2%
		
}

if $chapter_2_C6 ///
{
    use "MEAP93.dta", clear
	
	*第三小题
		g log_expend = log(expend)
		reg math10 log_expend
	
	*第四小题
		// 如果支出提高10%，估计math10会提高11.167/10=1.1167个百分点。
	
	*第五小题
		predict math10_hat, xb
		sum math10_hat
		// 所以在这个数据集中，即便expend取最大值，math10距离100也还差很远。
		
}

if $chapter_3_C3 ///
{
    use "CEOSAL2.dta", clear
	
	foreach v in salary sales mktval ///
	{
	    g log_`v' =log(`v')
	}
	
	*第一小题
		reg log_salary log_sales log_mktval
	
	*第二小题
		tab profit if profit<0
		// 表示有9个观测的profits小于0
		reg log_salary log_sales log_mktval profit
		// 这些变量解释了29.93%的变异
		
	*第三小题
		reg log_salary log_sales log_mktval profit ceoten
		// 延长一年CEO任期，估计的百分比回报增加1.16%。
	
	*第四小题
		cor log_mktval profits
		// 结果为0.7768976,说明在样本中，两者有较强的相关关系，存在共线性问题。		
		
}

if $chapter_3_C8 ///
{
	use "DISCRIM.dta", clear
	
	*第一小题
		sum prpblck income
		// prpblck是黑人/总人口的比值。income单位是美元
		
	*第二小题
		reg psoda prpblck income
	
	*第三小题
		reg psoda prpblck
		
	*第四小题
		reg lpsoda prpblck lincome
		// 如果prpblck提高0.20（即20个百分点），psoda的变化是0.20*0.12158 =0.024316，约为2.4%。
	
	*第五小题
		reg lpsoda prpblck lincome prppov
		// prpblck的系数为0.07281，比（4）中的系数下降了0.12158-0.07281=0.04877。
		
	*第六小题
		cor lincome prppov
	
}

if $chapter_7_1 ///
{
    capture noisily erase "$outpath\wage1_duplicate.dta"
	
    use "WAGE1.dta", clear
	
	list female in 1/5
	
	reg wage i.female educ exper tenure
	
	*In a program, you may want to invoke one of these commands which may change the data in memory, but you may want to retain the existing contents of memory for further use in the do-file. You need the "preserve" and "restore" commands, which will allow you to set aside the current contents of memory in a temporary file and bring them back when needed.
	
	preserve
	
	replace female = 2 if female == 1
	replace female = 1 if female == 0
	
	label var female "=2 if female"
	
	*By default, the lowest value is treated as the base level, and an indicator variable is produced for all levels except the base level.
	reg wage i.female educ exper tenure
	
	*capture noisily save "$outpath\wage1_duplicate.dta", replace
	
	restore
	
	
}

if $chapter_7_6 ///
{
    use "WAGE1.dta", clear
	
	preserve
	
	gen int marrmale=0 
	replace marrmale=1 if married == 1 & female == 0 

	gen int marrfem=0 
	replace marrfem=1 if married == 1 & female == 1 
	
	gen int singfem=0
	replace singfem=1 if married == 0 & female == 1	
	
	gen int singmale=0
	replace singmale=1 if married == 0 & female == 0		
	
	reg lwage i.marrmale i.marrfem i.singfem educ exper expersq tenure tenursq
	
	reg lwage i.marrmale i.singmale i.singfem educ exper expersq tenure tenursq
	
	restore
	
}

if $chapter_7_C12 ///
{
    use "BEAUTY.dta",clear
	
	*第一小题
	preserve
	keep if female == 1
	tab abvavg
	tab belavg
	restore
	// 女人相貌在一般水平之上的比例为33.03%，在一般水平之下的比例为13.53%
	preserve
	keep if female == 0
	tab abvavg
	tab belavg
	restore	
	// 男人相貌在一般水平之上的比例为29.00%，在一般水平之下的比例为11.65%
	
	*第二小题
	reg abvavg female
	// female的t统计量为1.48，p值为0.14。所在双侧10%的水平上不能认为女性相貌在一般水平之上的比例比男性多。我们认为男女相貌在一般水平上的总体比例相同。
	
	*第三小题
	cap gen int male = 0
	cap replace male = 1 if female == 0
	
	foreach v in female male /// 
	{
		reg lwage belavg abvavg if `v' == 1
	 
		display ttail(e(df_r),abs(_b[belavg]/_se[belavg]))
	}
	// 得到女性belavg系数的单侧p值为0.0358，在5%的水平显著；得到男性belavg系数的单侧p值为0.0004805，在1%的水平显著。
	
	*第四小题
	reg lwage belavg abvavg if female == 1
	 
	display ttail(e(df_r),abs(_b[abvavg]/_se[abvavg]))
	// abvavg的系数为0.03364，因此有一般相貌之上的女人比相貌一般的女人工资高3.364%，该系数的双侧p值为0.5442，除以2后得到单侧p值为0.2721。不显著。
	
	*第五小题
	foreach v in female male /// 
	{
		reg lwage belavg abvavg educ exper expersq union goodhlth black married south bigcity smllcity service ///
		if `v' == 1
	}
	/* 女性样本，增加解释变量后便belavg和abvavg的系数分别为-0.1151564和0.0575209，双侧p值分别为0.08170和0.23764。未增加时belavg和abvavg的系数分别为-0.13763和0.03364，双侧p值分别为0.0716和0.5442。无论是系数的大小还是显著度变化不大。
	
男性样本，增加后belavg和abvavg的系数分别为-0.1433863和-0.0010065，双侧p值分别为0.005183和0.978070。未增加时belavg和abvavg的系数分别为-0.19874和-0.04400，双侧p值分别为0.000961和0.299744。belavg的系数的大小和显著度变化不大，abvavg的系数绝对值变得更大，而且显著度有所提升。
	*/	
	
}

if $chapter_4_9 ///
{
	use "BWGHT.dta", clear
	
	preserve
		
	keep if motheduc != . & fatheduc != . // This data set contains information on 1,388 births, but we must be careful in counting the observations used in testing the null hypothesis. It turns out that information on at least one of the variables "motheduc" and "fatheduc" is missing for 197 births in the sample; these observations cannot be included when estimating the unrestricted model. Thus, we really have 1,191 observations.
	
	*有约束模型
	reg bwght cigs parity faminc
	
	scalar rss_r = e(rss)
	scalar q_r = e(df_m)
	scalar df_r = e(df_r)
	scalar r2_r = e(r2)
	
	*无约束模型
	reg bwght cigs parity faminc motheduc fatheduc
	
	scalar rss_u = e(rss)
	scalar q_u = e(df_m)
	scalar df_u = e(df_r)
	scalar r2_u = e(r2)
	
	*计算F统计量
	scalar q = q_u - q_r
	scalar F_1 = ((rss_r - rss_u)/q)/((rss_u)/(df_u))
	display "F统计量为 " F_1
	
	scalar F_2 = ((r2_u - r2_r)/q)/((1 - r2_u)/(df_u))
	display "F统计量为 " F_2
	
	test motheduc fatheduc
	
	restore
	
}

if $chapter_4_linear_restrictions ///
{
	use "HPRICE1.dta", clear
	
	preserve
	
	*无约束模型	
	reg lprice lassess llotsize lsqrft bdrms
	
	scalar q_u = e(df_m)
	scalar rss_u = e(rss)
	scalar df_u = e(df_r)
	
	*有约束模型	
	gen lprice_ = (lprice - lassess)
	reg lprice_

	scalar q_r = e(df_m)
	scalar rss_r = e(rss)
	scalar df_r = e(df_r)

	*计算F统计量
	scalar q = q_u - q_r
	scalar F = ((rss_r - rss_u)/q)/((rss_u)/(df_u))
	display "F统计量为 " F
	
	*Critical values for F at level 0.05	
	
	scalar alpha = 0.05
	scalar c_F = invFtail(q,df_u,alpha)
	
	display "Critical values " "F = " c_F
		
	restore
	
	//F检验的另外一种实现形式
	preserve
	
	gen lprice_ = (lprice - lassess)
	reg lprice_	lassess llotsize lsqrft bdrms
	test lassess llotsize lsqrft bdrms
	
	reg lprice lassess llotsize lsqrft bdrms
	test (lassess = 1) (llotsize = 0) (lsqrft = 0) (bdrms = 0)
	
	test lassess =  1
	test llotsize = 0, accumulate
	test lsqrft = 0, accumulate
	test bdrms = 0, accumulate
	
	restore
	
		
}

if $chapter_7_Chow_statistic /// 
{
	use "GPA3.dta", clear
	
	preserve
	
	keep if spring == 1
	
	*无约束模型
	reg cumgpa sat hsperc tothrs if female == 1
	
	scalar q_u_female = e(df_m) + 1
	scalar rss_u_female = e(rss)	
	
	reg cumgpa sat hsperc tothrs if female == 0
	
	scalar q_u_male = e(df_m) + 1
	scalar rss_u_male = e(rss)
	
	*有约束模型
	reg cumgpa sat hsperc tothrs
	
	scalar q_r = e(df_m) + 1
	scalar rss_r = e(rss)
	scalar observations = e(N)
	
	*计算F统计量
	scalar q = q_u_female + q_u_male - q_r
	scalar F = ((rss_r - rss_u_female - rss_u_male)/q)/ ///
			   ((rss_u_female + rss_u_male)/(observations - q_u_female - q_u_male))
	
	scalar list
	
	display "F统计量为 " F
	
	*参看资料:https://www.stata.com/support/faqs/statistics/computing-chow-statistic/
	
	*This definition of the “Chow test” is equivalent to pooling the data, fitting the fully interacted model, and then testing the group 2 coefficients against 0.
	
	reg cumgpa c.sat##i.female c.hsperc##i.female c.tothrs##i.female
	
	test 1.female 1.female#c.sat 1.female#c.hsperc 1.female#c.tothrs
	
	contrast female female#c.sat female#c.hsperc female#c.tothrs,overall
	
	test 1.female#c.sat 1.female#c.hsperc 1.female#c.tothrs
	
	contrast female#c.sat female#c.hsperc female#c.tothrs,overall
	
	restore
}

if $chapter_5_3	///
{
	use "CRIME1.dta",clear
	
	reg narr86 pcnv ptime86 qemp86
	
	predict e,resid
	
	reg e pcnv ptime86 qemp86 avgsen tottime
	
	scalar lm = e(N)*e(r2)
	
	display "LM = " lm " and p = " chi2tail(2,lm)
}

if $chapter_4_C2 ///
{
	use "LAWSCH85.dta", clear
	
	*第一小题
	reg lsalary LSAT GPA llibvol lcost rank
	// 这表示保持其他变量不变，法学院排名每下降1个名次（越好的学校排名的值越低，比如排第1的学校最好。），薪水上升0.33%。
	
	*第二小题
	test LSAT GPA
	
	*第三小题
	reg lsalary LSAT GPA llibvol lcost rank clsize faculty
	test clsize faculty
}

if $chapter_4_C5 ///
{
	use "MLB1.dta", clear
	
	*第一小题
	reg lsalary years gamesyr bavg hrunsyr
	
	*第二小题
	reg lsalary years gamesyr bavg hrunsyr runsyr fldperc sbasesyr
	
	*第三小题
	test bavg fldperc sbasesyr
}

if $chapter_7_C3 ///
{
	use "MLB1.dta", clear
	
	*第一小题
	reg lsalary years gamesyr bavg hrunsyr rbisyr runsyr fldperc allstar frstbase scndbase thrdbase shrtstop catcher
	// 在控制其他变量不变的条件下，接球手（catcher）和外场手（outfield，作为基组而不存在于模型中）的工资差异约为100*[exp(0.2535592)-1]= 28.86037%。
	
	*第二小题
	test frstbase scndbase thrdbase shrtstop catcher
	
}

if $chapter_7_C4 ///
{
	use "GPA2.dta", clear
	
	*第二小题
	reg colgpa hsize hsizesq hsperc sat i.female i.athlete 
	
	*第三小题
	reg colgpa hsize hsizesq hsperc i.female i.athlete 
	
	*第四小题
	preserve
	
	gen int malenonath=0 
	replace malenonath=1 if athlete == 0 & female == 0

	gen int femnonath=0 
	replace femnonath=1 if athlete == 0 & female == 1
	
	gen int maleath=0
	replace maleath=1 if athlete == 1 & female == 0	
	
	gen int femath=0
	replace femath=1 if athlete == 1 & female == 1
	
	reg colgpa hsize hsizesq hsperc sat i.malenonath i.femnonath i.maleath
	
	restore
	
	*第五小题
	reg colgpa hsize hsizesq hsperc i.female##c.sat i.athlete
		
}

if $chapter_7_C6 ///
{
	use "FERTIL2.dta", clear	
	
	*第一小题
	reg children educ age agesq urban electric tv
	
	*第三小题
	reg children c.educ##i.urban c.age##i.urban c.agesq##i.urban c.electric##i.urban c.tv##i.urban
	
	contrast urban urban#c.educ urban#c.age urban#c.agesq urban#c.electric urban#c.tv, overall
	
	*第四小题
	contrast urban#c.educ urban#c.age urban#c.agesq urban#c.electric urban#c.tv, overall
}

if $chapter_8_4_8_5 ///
{
	use "HPRICE1.dta",clear
	
	*BP检验
	reg price lotsize sqrft bdrms
	
	estat hettest lotsize sqrft bdrms, iid // "iid" causes estat hettest to compute the N*R2 version of the score test that drops the normality assumption.
	
	estat hettest lotsize sqrft bdrms, fstat // "fstat" causes estat hettest to compute the F-statistic version that drops the normality assumption.

	
	reg lprice llotsize lsqrft bdrms
	
	estat hettest llotsize lsqrft bdrms, iid
	
	estat hettest llotsize lsqrft bdrms, fstat
	
	*怀特检验
	predict e,resid
	predict lprice_hat,xb
	g e2=e^2
	g lprice_hat_2 = (lprice_hat)^2
	
	reg e2 lprice_hat lprice_hat_2
	
	scalar lm = e(N)*e(r2)
	display "LM = " lm " and p = " chi2tail(2,lm)

}

if $chapter_8_7	///
{
    use "SMOKE.dta",clear
	
	reg cigs lincome lcigpric educ age agesq restaurn
	estat hettest lincome lcigpric educ age agesq restaurn, iid // “这是异方差极强的证据”
	
	predict e,resid
	g e2 = e^2
	g lne2 = log(e2)
	
	reg lne2 lincome lcigpric educ age agesq restaurn
	predict lne2_fitted,xb
	g e2_fitted = exp(lne2_fitted)
	
	reg cigs lincome lcigpric educ age agesq restaurn [aw=1/e2_fitted]
	
	
}

if $chapter_9_2 ///
{
    use "HPRICE1.dta",clear
	
	reg price lotsize sqrft bdrms
	estat ovtest
	estat ovtest,rhs
	linktest
	
	predict price_hat,xb
	forvalue v = 2/4 ///
	{
		g price_hat_`v' = price_hat^`v'
	}
	
	reg price lotsize sqrft bdrms price_hat_2 price_hat_3
	test price_hat_2 price_hat_3
	
	reg price lotsize sqrft bdrms price_hat_2 price_hat_3 price_hat_4
	test price_hat_2 price_hat_3 price_hat_4
	
}
*   =====================================================================

cap log close

*   DONE
*   =====================================================================
