/* 
***************************************************************************
	Name of file: 	李子奈第四版程序.do
		
	Files Used:		2.1.1
					2.3.1
					2.6.1
					2.12_练习
					3.2.2
					3.5.1
					3.6.1
					3.7.2
					3.14_练习
					3.17_练习
					4.1.1
					4.2.4
					4.3.4
					4.11_练习
					4.12_练习
					4.13_练习
					5.1.1
					5.2_练习
					grilic
					
				
				
*************************************************************************** 
*/

set more off

global path_Li "C:\Users\jiacheng pan\Desktop\2020年春计量经济学实验课\李子奈第四版程序"  // Add your local directory here

global outpath_Li "${path_Li}\Results"
cap mkdir "$outpath_Li"

global dta_path_Li "${path_Li}\data" 
cd "${dta_path_Li}" 

*   ===============================
*	Choose sections to run
*   ===============================

// Set to 1 if want section run, 0 otherwise

global	code_2_1_1			   			1
global	code_2_3_1						1
global	code_2_6_1						1
global	code_2_12						1
global	code_3_2_2						1
global	code_3_5_1						1
global	code_3_6_1						1
global	code_3_7_1						1
global	code_3_7_2						1
global	code_3_7_3						1
global	code_3_14						1
global	code_3_15						1
global	code_3_16						1
global	code_3_17						1
global	code_4_1_1						1
global	code_multicollinearity			1
global	code_4_2_4						1
global	code_4_3_4						1
global	code_4_4_1						1


*   ===============================
/*
cap log close
log using "$outpath_Li\Analysis ($S_DATE).log", replace
*/
*   ===============================

if $code_2_1_1 == 1 ///
{
	
	use "2.1.1.dta", clear
	
	scatter y x || ///
	lfit y x, ///
	title("不同可支配收入水平组家庭消费支出的条件分布图") ///
	name("不同可支配收入水平组家庭消费支出的条件分布图", replace)
	
}

if $code_2_3_1 == 1 ///
{
	
	use "2.3.1.dta", clear
	
	
	generate b1=xiyisum/xi2sum in 1
	display b1
	generate b2=Yimean-b1*Ximean in 1
	display b2
	
}

if $code_2_6_1 == 1 ///
{
	use "2.6.1.dta", clear
	
	reg Y X
	
	*Microeconometrics Using Stata 1.6.2
	
	*Estimation commands are e-class commands (or estimation-class commands),such as regress. The results are stored in e(), the contents of which you canview by typing "ereturn list".

	ereturn list
	
	* Use of e() where scalar
	scalar r2 = e(mss)/(e(mss)+e(rss))
	display " r-squared = " r2

	adjust X=20000,ci se
	
}

if $code_2_12 == 1 ///
{
	use "2.12.dta", clear
	
	*第一小题
	scatter Y GDP || lfit Y GDP
	
	reg Y GDP
	
	*第二小题
	*Critical values for t at level 0.05	
	scalar alpha = 0.05
	scalar c_t29 = invttail(29,alpha/2)
	display "Critical values" "t(29) = " c_t29
	
	adjust GDP=8500,ci se
	adjust GDP=8500,ci stdf
	
}

if $code_3_2_2 == 1 ///
{
    use "3.2.2.dta", clear
	
	reg Y X1 X2
	display e(rss)
	display e(df_r) 

}

if $code_3_5_1 == 1 ///
{
    use "3.5.1.dta", clear
	
	///双对数线性回归模型
	g lnY=ln(Y)
	g lnK=ln(K) 
	g lnL=ln(L)
	reg lnY lnK lnL
	display e(r2)
	display e(F)
	
	///判断估计的生产函数是否具有规模收益不变的特征
	constraint 1 lnK+lnL=1
	cnsreg lnY lnK lnL,constraint(1)
	drop lnY lnK lnL 
	g lnYL=ln(Y/L)
	g lnKL=ln(K/L)
	reg lnYL lnKL
}

if $code_3_6_1 == 1 ///
{
    use "3.6.1.dta", clear
	
	reg Y X1 X2 i.D i.D#c.X1 i.D#c.X2
	reg Y X1 X2 i.D#c.X2

}

if $code_3_7_1 == 1 ///
{
    use "3.5.1.dta", clear
	
	g lnY=ln(Y)
	g lnK=ln(K) 
	g lnL=ln(L)
	g lnYL=ln(Y/L)
	g lnKL=ln(K/L)
	
	reg lnY lnK lnL
	display e(rss)
	display e(df_r)
	
	reg lnYL lnKL
	display e(rss)
	display e(df_r)
	
}

if $code_3_7_2 == 1 ///
{
    use "3.7.2.dta", clear
	
	*无约束模型
	reg lnQ lnXP0 P1P P2P P01 P02 P03
	
	scalar rss_u = e(rss)
	scalar df_u = e(df_r)
	scalar q_u = e(df_m)
	
	*有约束模型
	reg lnQ lnXP0 P1P P2P
	
	scalar rss_r = e(rss)
	scalar df_r = e(df_r) // residual degrees of freedom
	scalar q_r = e(df_m)
	
	
	*计算F统计量
	scalar q = q_u - q_r
	scalar F = ((rss_r - rss_u)/q)/((rss_u)/(df_u))
	
	display "相应的F检验为 " F
	
	*Critical values for t F at level 0.05	
	
	scalar alpha = 0.05
	scalar c_F = invFtail(q,df_u,alpha)
	
	display "Critical values" " F = " c_F

}

if $code_3_7_3 == 1 ///
{
    use "3.6.1.dta", clear
	
	reg Y c.X1##i.D c.X2##i.D 
	
	contrast D D#c.X1 D#c.X2,overall
	
}

if $code_3_14 == 1 ///
{
	use "3.14.dta", clear
	
	reg Y X1 X2
	
	display e(rss)
	display e(df_r)
	display e(r2)
	display e(r2_a)
	display e(F)
	
	*Critical values for t F at level 0.05	
	
	scalar alpha = 0.05
	scalar c_t7 = invttail(e(df_r),alpha/2)
	scalar c_F_2_7 = invFtail(2,e(df_r),alpha)
	
	display "Critical values" "t(7) = " c_t7
	display "Critical values" "F(2,7) = " c_F_2_7
	
	adjust X1=35 X2=20000,ci se
}

if $code_3_15 == 1 ///
{
	use "3.6.1.dta", clear
	
	reg Y X1 X2 i.D i.D#c.X1 i.D#c.X2
	display e(r2)
	display e(N)
	display e(df_r)

	test 1.D 1.D#c.X1
	
	test 1.D 1.D#c.X1 1.D#c.X2
}

if $code_3_16 == 1 ///
{
	use "3.7.2.dta", clear
	
	reg lnQ lnXP0 P1P P2P P01 P02 P03
	display e(rss)
	display e(df_r)
	
	reg lnQ lnXP0 P1P P2P
	display e(rss)
	display e(df_r)	
}

if $code_3_17 == 1 ///
{
	use "3.17.dta", clear
	
	g lnY=ln(Y)
	g lnK=ln(K)
	g lnL=ln(L)
	
	reg lnY lnK lnL
	display e(rss)
	display e(df_r)
	
	g lnYL=ln(Y/L)
	g lnKL=ln(K/L)
	
	reg lnYL lnKL
	display e(rss)
	display e(df_r)
}

if $code_4_1_1 == 1 ///
{
	use "4.1.1.dta", clear
	
	g lnY=ln(Y)
	g lnX1=ln(X1)
	g lnX2=ln(X2)
	g lnX3=ln(X3)
	g lnX4=ln(X4)
	g lnX5=ln(X5)
	g lnX6=ln(X6)
	reg lnY lnX1 lnX2 lnX3 lnX4 lnX5 lnX6
	
	scalar q = e(df_m)
	scalar alpha = 0.05
	scalar c_F = invFtail(q,e(df_r),alpha)
	display "Critical values " "F = " c_F
	
	///检验简单相关系数
	corr lnX1 lnX2 lnX3 lnX4 lnX5 lnX6
	
	///逐步向前回归
	sw reg lnY lnX1-lnX6, pe(0.05)
	sw reg lnY lnX1-lnX6, pe(0.10)
	
	//逐步向后回归
	sw reg lnY lnX1-lnX6, pr(0.05)
	sw reg lnY lnX1-lnX6, pr(0.10)
}

if $code_multicollinearity == 1 ///
{	
	twoway function VIF=1/(1-x),xtitle(R2) ///
	xline(0.9,lp(dash)) yline(10,lp(dash)) ///
	xlabel(0.1(0.1)1) ylabel(10 100 200 300)
	
	use "grilic.dta", clear
	// 以数据集 grilic.dta 为例，该数据集包括758名美国年轻男子的数据。
	//被解释变量为 lnw (工资对数)，主要解释变量包括s (教育年限)、expr (工龄)、tenure (在现单位工作年限)、smsa (是否住在大城市)以及rns (是否住在美国南方)。
	
	qui reg lnw s expr tenure smsa rns
	estat vif
	
	cap g s2=s^2
	reg lnw s s2 expr tenure smsa rns
	estat vif
	
	reg s2 s
	
	sum s
	cap g sd=(s-r(mean))/r(sd)
	cap g sd2=sd^2
	
	reg lnw sd sd2 expr tenure smsa rns
	estat vif
	
	reg sd2 sd
	reg lnw sd expr tenure smsa rns
	reg lnw s expr tenure smsa rns
}

if $code_4_2_4 == 1 ///
{
	use "4.2.4.dta", clear
	
	// 回归
	g lnY=ln(Y)
	g lnX1=ln(X1)
	g lnX2=ln(X2)
	reg lnY lnX1 lnX2

	//绘制残差图
	rvfplot // // rvfplot graphs a residual-versus-fitted plot, a graph of the residuals against the fitted values.
	
	rvpplot lnX2,title("图4.2.3 异方差性检验图") // rvpplot graphs a residual-versus-predictor plot (a.k.a. independent variable plot or carrier plot), a graph of the residuals against the specified predictor.
	*可能存在着递增的异方差性
	
	//B-P检验
	estat hettest lnX1 lnX2, iid
	*书本涉及的F检验有问题
	
	//B-P检验（按照书上的步骤）
	cap predict e,resid
	cap g e2=e^2
	
	reg e2 lnX1 lnX2
	
	scalar lm = e(N)*e(r2)
	display "LM = " lm " and p = " chi2tail(2,lm)
	
	//怀特检验（按照书上的步骤）	
	cap g lnX12=(lnX1)^2
	cap g lnX22=(lnX2)^2
	cap g lnX1lnx2=(lnX1)*(lnX2)
	
	reg e2 lnX1 lnX2 lnX12 lnX22 lnX1lnx2

	scalar lm = e(N)*e(r2)
	display "LM = " lm  	

	test lnX1 lnX2 lnX12 lnX22 lnX1lnx2

	//异方差稳健标准误
	reg lnY lnX1 lnX2
	reg lnY lnX1 lnX2,robust

	//WLS（按照书上的步骤）
	g lne2=log(e2)
	reg lne2 lnX2 lnX22
	
	*求权重
	predict lne2f,xb
	g e2f=exp(lne2f)
	
	*进行回归
	reg lnY lnX1 lnX2 [aw=1/e2f]
}

if $code_4_3_4 == 1 ///
{
	use "4.3.4.dta", clear
   
	g lnQ=ln(Q)
	g lnY=ln(Y)
	g lnP=ln(P)
	g lnTAX=ln(TAX)
	g lnTAXS=ln(TAXS)
	
	///普通最小二乘
	reg lnQ lnY lnP
	
	///2SLS
	///用TAX作为工具变量
	ivregress 2sls lnQ lnY (lnP= TAX)
	
	///用TAX、TAXS作为工具变量
	ivregress 2sls lnQ lnY (lnP=TAXS TAX)
	estat endogenous lnP
	estat overid
	
	///豪斯曼检验（按照书上的步骤）
	reg lnP lnY TAX TAXS
	predict v,resid
	reg lnQ lnY lnP v

}

if $code_4_4_1 == 1 ///
{
    use "4.3.4.dta", clear
	
	g lnQ=ln(Q)
	g lnY=ln(Y)
	g lnP=ln(P)
	g lnTAX=ln(TAX)
	g lnTAXS=ln(TAXS)
	reg lnQ lnY lnP

	//RESET检验(书上的步骤)
	predict lnQhat,xb
	g lnQhat2=lnQhat^2
	g lnQhat3=lnQhat^3
	g lnQhat4=lnQhat^4
	
	reg lnQ lnY lnP lnQhat2
	test lnQhat2	
	
	reg lnQ lnY lnP lnQhat2 lnQhat3
	test lnQhat2 lnQhat3
	
	//简单的线性模型
	reg Q Y P	
	predict Qhat,xb
	g Qhat2=Qhat^2
	reg Q Y P Qhat2 
	test Qhat2 
}

*   =====================================================================
cap log close

*   DONE
*   =====================================================================
