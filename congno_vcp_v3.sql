Select sum(base7.amount)

--base7.company_code
--,base7.company_code_kh
--,base7.company_code_ncc
--,base7.company_name
--,base7.group_code
--,base7.group_name
--,sum(case when base7.account_group = '131' then base7.amount else 0 end) as total_amount_131
--,sum(case when base7.account_group = '331' then base7.amount else 0 end) as total_amount_331
--,sum(case when base7.is_finished = 0 and base7.account_group = '131' then base7.total_pdd_amount else 0 end) as pending_tt_total_paid_131
--,sum(case when base7.is_finished = 0 and base7.account_group = '131' then  isnull(base7.amount,0) - isnull(base7.total_pdd_amount,0) else 0 end) as pending_tt_total_remaining_131
--,sum(case when base7.is_finished = 0 and base7.account_group = '331' then base7.pdd_pt2_amount else 0 end) as pending_tt_total_paid_331
--,sum(case when base7.is_finished = 0 and base7.account_group = '331' then  isnull(base7.amount,0) - isnull(base7.pdd_pt2_amount,0) else 0 end) as pending_tt_total_remaining_331
--,base7.pdd_pt2_amount 
--,base7.amount


from
(Select *

,case when base6.account_group = '331' then 0 -- minh mua / minh tra, khong quan tam lead time cong no
	  when base6.account_group = '131' then -- khach mua / khach tra, quan tam den leadtime cong no
		   case when base6.pay_type = 2 then 0 -- chung tu khach tra tien, 1 chung tu co the tra cho nhieu hoa don
			    when base6.Stt in ('') then null -- dung khi can loai cac chung tu khong can tinh leadtime
				when base6.is_finished = 1 then 
					 case when DATEDIFF(DAY,base6.doc_date,base6.max_doc_date_tt_final) >= 0 then DATEDIFF(DAY,base6.doc_date,base6.max_doc_date_tt_final) else 0 end
			    when base6.is_finished = 0 then DATEDIFF(DAY,base6.doc_date,cast(getdate() as DATE))				
           else 0 end
	  else 0  end as leadtime_tt

from
		(Select 'vcp' as entity
		,base5.id
		,base5.Stt as stt
		,base5.DocCode as doc_code
		,base5.DocDate as doc_date
		,base5.DocNo as doc_no
		,base5.DocDateAcc as doc_date_acc
		,base5.DocNoAcc as doc_no_acc
		,base5.Description as description
		,base5.PayType as pay_type
		,base5.Account as account
		,base5.account_group
		,base5.CustomerCode as customer_code
		,base5.DueDate as due_date
		,base5.CurrencyCode as currency_code
		,base5.Year as year
		,base5.amount -- tong tien theo hoa don
		,base5.pdd_amount
		,base5.pdd_amount_extra
		,base5.total_pdd_amount -- tong tien da thu cua khach hang
		,base5.pdd_pt2_amount -- tong tien da tra nha cung cap
		,base5.max_doc_date_tt
		,base5.max_doc_date_tt_extra
		,base5.max_doc_date_tt_final

		,case when base5.PayType = 1 and base5.amount <> base5.total_pdd_amount then 0
			  when base5.PayType = 2 and base5.amount <> base5.pdd_pt2_amount then 0
			  when base5.Stt in ('') then 1 -- dung khi can loai cac chung tu xem nhu da hoan thanh
			  else 1 end as is_finished
		,group_info.company_code
		,group_info.company_code_kh
		,group_info.company_code_ncc
		,group_info.group_code
		,group_info.group_name
		,cl.customer_name as company_name			
			

		from 
			(Select base4.Id
			,base4.Stt
			,base4.TransCode
			,base4.DocCode
			,base4.DocDate
			,base4.DocNo
			,base4.DocDateAcc
			,base4.DocNoAcc
			,base4.Description
			,base4.PayType
			,base4.IsPrepayment
			,base4.Account
			,base4.CustomerCode
			,base4.DueDate
			,base4.CurrencyCode
			,base4.ExchangeRate
			,base4.Year
			,base4.AtchDocDate
			,base4.AtchDocNo
			,base4.IsActive
			,base4.CreatedAt
			,base4.account_group
			,base4.ad_is_active
			,base4.Posted
			,base4.DocStatus
			,base4.doc_year
			,base4.max_doc_date_tt
			,base4.max_doc_date_tt_extra 
			,case when base4.max_doc_date_tt is null and  base4.max_doc_date_tt_extra is null then null
				when isnull(base4.max_doc_date_tt,'') >= isnull(base4.max_doc_date_tt_extra,'') then isnull(base4.max_doc_date_tt,'')
				else isnull(base4.max_doc_date_tt_extra,'') end as max_doc_date_tt_final

			,case when base4.account_group = '331' and base4.PayType = 1 then isnull(base4.Amount,0)
						when base4.account_group = '331' and base4.PayType = 2 then (-1)*isnull(base4.Amount,0)
						when base4.account_group = '131' and base4.PayType = 1 then (-1)*isnull(base4.Amount,0)
						when base4.account_group = '131' and base4.PayType = 2 then isnull(base4.Amount,0)
						else isnull(base4.Amount,0) end as amount

			,case when base4.account_group = '331' and base4.PayType = 1 then isnull(base4.pdd_amount,0)
						when base4.account_group = '331' and base4.PayType = 2 then (-1)*isnull(base4.pdd_amount,0)
						when base4.account_group = '131' and base4.PayType = 1 then (-1)*isnull(base4.pdd_amount,0)
						when base4.account_group = '131' and base4.PayType = 2 then isnull(base4.pdd_amount,0)
						else isnull(base4.pdd_amount,0) end as pdd_amount

			,isnull(base4.pdd_amount_extra,0) as pdd_amount_extra

			,case when base4.account_group = '331' and base4.PayType = 1 then isnull(base4.pdd_amount,0)
						when base4.account_group = '331' and base4.PayType = 2 then (-1)*isnull(base4.pdd_amount,0)
						when base4.account_group = '131' and base4.PayType = 1 then (-1)*isnull(base4.pdd_amount,0)
						when base4.account_group = '131' and base4.PayType = 2 then isnull(base4.pdd_amount,0)
						else isnull(base4.pdd_amount,0) end + isnull(base4.pdd_amount_extra,0) as total_pdd_amount

			,case when base4.account_group = '331' and base4.PayType = 1 then isnull(base4.pdd_pt2_amount,0)
						when base4.account_group = '331' and base4.PayType = 2 then (-1)*isnull(base4.pdd_pt2_amount,0)
						when base4.account_group = '131' and base4.PayType = 1 then (-1)*isnull(base4.pdd_pt2_amount,0)
						when base4.account_group = '131' and base4.PayType = 2 then isnull(base4.pdd_pt2_amount,0)
						else isnull(base4.pdd_pt2_amount,0) end as pdd_pt2_amount

			from
				(Select base3.*
				,sum(pdd_pt2.Amount) as pdd_pt2_amount
				,max(pdd_pt2.DocDate_Tt) as pdd_pt2_max_doc_date_tt -- chua dung

	

				from
					(Select base2.Id
					,base2.Stt
					,base2.TransCode
					,base2.DocCode
					,base2.DocDate
					,base2.DocNo
					,base2.DocDateAcc
					,base2.DocNoAcc
					,base2.Description
					,base2.PayType
					,base2.IsPrepayment
					,base2.Account
					,base2.CustomerCode
					,base2.DueDate
					,base2.CurrencyCode
					,base2.ExchangeRate
					,base2.Amount
					,base2.Year
					,base2.AtchDocDate
					,base2.AtchDocNo
					,base2.IsActive
					,base2.CreatedAt
					,base2.account_group
					,base2.ad_is_active
					,base2.Posted
					,base2.DocStatus
					,base2.doc_year
					,base2.pdd_amount
					,base2.max_doc_date_tt
					,max(base2.max_doc_date_tt_extra) as max_doc_date_tt_extra
					,sum(case when base2.bdk_account_group = '331' and base2.PayType = 1 then base2.pdd_amount_extra
								when base2.bdk_account_group = '331' and base2.PayType = 2 then (-1)*base2.pdd_amount_extra
								when base2.bdk_account_group = '131' and base2.PayType = 1 then (-1)*base2.pdd_amount_extra
								when base2.bdk_account_group = '131' and base2.PayType = 2 then base2.pdd_amount_extra
								else base2.pdd_amount_extra end) as pdd_amount_extra

					from
						(Select base1.*
						,bdk.account_group as bdk_account_group
						,sum(case -- when base1.Stt = 'B010000000225460' then 341999910 -- exceptional case: C24TCP692 co C24TCP1093 dieu chinh giam
									when base1.Stt = 'B010000000096229' then 	33926407 -- exceptional case: 0005961 bi nham thanh 0005916 trong B0100000178513DK
									when base1.Stt = 'B010000000096491' then 17999999 - 7852403 -- exceptional case: phieu goc da thanh toan 7852403, phieu DK B0100000178531DK lai thanh toan full
									when base1.Stt = 'B010000000110507' then 60890952 -- exceptionao case: M0217, docno 2020323
									when base1.Stt = 'B010000000114043' then 2651971 -- exceptionao case: M0217, docno 2020323
									when base1.Stt = 'B010000000206316' then 22259160.00 -- exceptionao case: M0217, docno P-149
									when base1.Stt = 'B010000000206317' then 54458250.00 -- exceptionao case: M0217, docno P-150
									when base1.Stt = 'B010000000223973' then 80322.00 -- exceptionao case: D0167, docno P-439
								else bdk.pdd_amount_for_dk end) as pdd_amount_extra
						,max(bdk.doc_date_tt_for_dk) as max_doc_date_tt_extra
				 

						from
							(select base.Id
							,base.Stt
							,base.TransCode
							,base.DocCode
							,base.DocDate
							,base.DocNo
							,base.DocDateAcc
							,base.DocNoAcc
							,base.Description
							,base.PayType
							,base.IsPrepayment
							,base.Account
							,base.CustomerCode
							,base.DueDate
							,base.CurrencyCode
							,base.ExchangeRate
							,base.Amount
							,base.Year
							,base.AtchDocDate
							,base.AtchDocNo
							,base.IsActive
							,base.CreatedAt
							,base.account_group
							,base.ad_is_active
							,base.Posted
							,base.DocStatus
							,base.doc_year
							,sum(pdd_2.Amount) as pdd_amount
							,max(pdd_2.DocDate_Tt) as max_doc_date_tt




							from
								(Select pd.*
								,case when pd.Account like '131%' then '131'
										when pd.Account like '331%' then '331'
										else N'Others' end as account_group
								,ad.IsActive  as ad_is_active
								,ad.Posted
								,ad.DocStatus
								,year(pd.DocDate) as doc_year

								from B7R2_VCP_TH.dbo.B30PayDoc pd
									left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt and ad.CustomerCode = pd.CustomerCode
								--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Id = pdd.ParentId
								--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on pd.Stt = pdd_2.Stt_Cd_Htt and pd.CustomerCode = pdd_2.CustomerCode

								where 1=1
								and isnull(ad.IsActive,1) = 1
								and (pd.IsOpenBalance = 0 OR (pd.IsOpenBalance = 1 and pd.Year = 2018) OR pd.Stt in ('B0100000408421DK')) -- exceptional
								and pd.IsActive = 1 -- mới thêm
								and pd.Stt not in ('B0100000408421DK')
		
								)base
									left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on base.Stt = pdd_2.Stt_Cd_Htt and base.CustomerCode = pdd_2.CustomerCode and pdd_2.IsActive = 1 and (pdd_2.Account LIKE '131%' OR pdd_2.Account LIKE '331%') and base.Account = pdd_2.Account

				

							where 1=1
							and isnull(base.CustomerCode,'') <> ''
							and base.Stt not in ('B010000000177365')

							--and base.CustomerCode = 'B0023'
							--and base.DocNo = '0001242'

							GROUP BY base.Id,base.Stt,base.TransCode,base.DocCode,base.DocDate,base.DocNo,base.DocDateAcc,base.DocNoAcc,base.Description,base.PayType,base.IsPrepayment,base.Account,base.CustomerCode,base.DueDate,base.CurrencyCode,base.ExchangeRate,base.Amount,base.Year,base.AtchDocDate,base.AtchDocNo,base.IsActive,base.CreatedAt,base.account_group,base.ad_is_active,base.Posted,base.DocStatus,base.doc_year

							)base1
								left join (Select pd.Stt
											,pd.DocCode
											,case when pd.Stt = 'B0100000463962DK' then '2024-12-30' -- exceptional case chung tu C24TCP14457 co record DK bi lech 1 ngay (2024-12-31) so voi ngay dung (2024-12-31)
												else pd.DocDate end as DocDate
											,pd.DocNo
											,pd.Description
											,pd.Account
											,case when pd.Account like '131%' then '131'
													when pd.Account like '331%' then '331'
												else N'Others' end as account_group
											,pd.PayType
											,pd.CustomerCode
											,pd.Amount
											,sum(pdd.Amount) as pdd_amount_for_dk
											,max(pdd.DocDate_Tt) as doc_date_tt_for_dk
				
											from B7R2_VCP_TH.dbo.B30PayDoc pd 
												left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Stt = pdd.Stt_Cd_Htt and pd.CustomerCode = pdd.CustomerCode and pdd.IsActive = 1 and (pdd.Account LIKE '131%' OR pdd.Account LIKE '331%') and pd.Account = pdd.Account
								
											where 1=1
											and pd.IsActive = 1
											and pd.Stt  like '%DK%'
											and pd.Stt not in ('B0100000288691DK','B0100000402427DK','B0100000350074DK','B0100000178532DK','B0100000180049DK','B0100000351776DK','B0100000351413DK','B0100000180013DK','B0100000180021DK',
																'B0100000180018DK','B0100000180023DK','B0100000180027DK','B0100000180028DK','B0100000180031DK','B0100000180033DK','B0100000180034DK','B0100000180036DK','B0100000180040DK',
																'B0100000180042DK','B0100000180044DK','B0100000180047DK','B0100000256114DK','B0100000180453DK','B0100000180448DK','B0100000180451DK','B0100000180454DK','B0100000180458DK',
																'B0100000180601DK','B0100000180673DK','B0100000180009DK'
																) -- exceptional cases / clean data
										--	and year(pd.DocDate) >= 2018
										--	and ((year(pd.DocDate) >= 2018 and isnull(pd.DocNo,'') <> '') OR (year(pd.DocDate) < 2018 and isnull(pd.DocNo,'') = ''))

											GROUP BY pd.Stt
													,pd.DocCode
													,pd.DocDate
													,pd.DocNo
													,pd.Description
													,pd.Account
													,pd.PayType
													,pd.CustomerCode
													,pd.Amount
							
											)bdk on bdk.DocCode = base1.DocCode and bdk.DocNo = base1.DocNo and bdk.CustomerCode = base1.CustomerCode and bdk.Stt <> base1.Stt and base1.DocDate = bdk.DocDate

						GROUP BY base1.Id,base1.Stt,base1.TransCode,base1.DocCode,base1.DocDate,base1.DocNo,base1.DocDateAcc,base1.DocNoAcc,base1.Description,base1.PayType,base1.IsPrepayment,base1.Account,base1.CustomerCode,base1.DueDate,base1.CurrencyCode,base1.ExchangeRate,base1.Amount,base1.Year,base1.AtchDocDate,base1.AtchDocNo,base1.IsActive,base1.CreatedAt,base1.account_group,base1.ad_is_active,base1.Posted,base1.DocStatus,base1.doc_year,base1.pdd_amount,bdk.account_group,base1.max_doc_date_tt

						)base2

					GROUP BY base2.Id,base2.Stt,base2.TransCode,base2.DocCode,base2.DocDate,base2.DocNo,base2.DocDateAcc,base2.DocNoAcc,base2.Description,base2.PayType,base2.IsPrepayment,base2.Account,base2.CustomerCode,base2.DueDate,base2.CurrencyCode,base2.ExchangeRate,base2.Amount,base2.Year,base2.AtchDocDate,base2.AtchDocNo,base2.IsActive,base2.CreatedAt,base2.account_group,base2.ad_is_active,base2.Posted,base2.DocStatus,base2.doc_year,base2.pdd_amount,base2.max_doc_date_tt

				)base3
					left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_pt2 on base3.Stt = pdd_pt2.Stt and base3.PayType = 2 and pdd_pt2.IsActive = 1 and base3.CustomerCode = pdd_pt2.CustomerCode and base3.Account = pdd_pt2.Account

				-- where 1=1 and base3.Stt = 'B010000000269265'
	

				GROUP BY base3.Id,base3.Stt,base3.TransCode,base3.DocCode,base3.DocDate,base3.DocNo,base3.DocDateAcc,base3.DocNoAcc,base3.Description,base3.PayType,base3.IsPrepayment,base3.Account,base3.CustomerCode,base3.DueDate,base3.CurrencyCode,base3.ExchangeRate,base3.Amount,base3.Year,base3.AtchDocDate,base3.AtchDocNo,base3.IsActive,base3.CreatedAt,base3.account_group,base3.ad_is_active,base3.Posted,base3.DocStatus,base3.doc_year,base3.pdd_amount,base3.pdd_amount_extra ,base3.max_doc_date_tt,base3.max_doc_date_tt_extra

			)base4
	
			)base5
					left join (Select base.*
									,gl.group_code
									,gl.group_name

									from
									(Select cl.*
									,two_side.company_code_ncc as two_side_company_code_ncc
									,two_side.company_code_kh as two_side_company_code_kh
									,case when two_side.company_code_ncc is not null then
												case when two_side.company_code_kh is not null then two_side.company_code_kh
												else two_side.company_code_ncc end
										  else cl.customer_code end as company_code
									,case when two_side.company_code_ncc is not null then two_side.company_code_ncc
										  when (cl.customer_code like N'B%'	OR cl.customer_code like N'KL%') then ''
										  else cl.customer_code
										  end as company_code_ncc
									,case when two_side.company_code_ncc is not null then two_side.company_code_kh
										  when (cl.customer_code like N'B%'	OR cl.customer_code like N'KL%') then cl.customer_code
										  else '' 
										  end as company_code_kh
	  

									from test_db.dbo.customer_list_v2 cl
										left join test_db.dbo.group_list two_side on cl.customer_code = two_side.company_code_ncc
	

									where 1=1
									-- and two_side.company_code_ncc is null
									-- and two_side.company_code_kh is null 
									-- and gl.company_code is not null 
									-- and cl.customer_code = 'M0174'
									)base
										left join test_db.dbo.group_list gl on gl.company_code = base.company_code


								)group_info on base5.CustomerCode = group_info.customer_code 
								left join test_db.dbo.customer_list_v2 cl on group_info.company_code = cl.customer_code


		



			where 1=1
		--	and base5.PayType = 1
		--	and base5.amount <> base5.pdd_pt2_amount
		--	and base5.CustomerCode = 'B0205'
		--	and base5.total_pdd_amount <> 0
		--	and base5.pdd_pt2_amount <> 0
		--	and base5.total_pdd_amount <> base5.amount
		--	and base5.Stt = 'B010000000145411'
		--	and DATEDIFF(DAY,base5.DocDate,base5.max_doc_date_tt_final) < 0	

	)base6
		where 1=1
	--	and base6.pay_type = 1
	--	and base6.is_finished = 0
)base7

where 1=1
-- and base7.company_code = 'M0021'


--GROUP BY base7.company_code
--,base7.company_code_kh
--,base7.company_code_ncc
--,base7.company_name
--,base7.group_code
--,base7.group_name