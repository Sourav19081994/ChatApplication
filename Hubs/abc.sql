USE [Khupho]
GO
/****** Object:  StoredProcedure [dbo].[AssignProperty]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[AssignProperty]
(
@PropertyId varchar(50),
@AgentId	varchar(50)
)
as
begin
if Exists(select * from [dbo].[Property_tbl] where PropertyId=@PropertyId)
begin
Update [Property_tbl] set CreatedBy=@AgentId where PropertyId=@PropertyId
end
end



GO
/****** Object:  StoredProcedure [dbo].[changePassword_Admin]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[changePassword_Admin]
(
 @LoginId bigint = null,
 @Password nvarchar(500)=null,
 @Confirm_Password nvarchar(500)=null,
 @newPass nvarchar(500)=null
)
as
begin
    declare @OldPass nvarchar(500)
    
    select @OldPass=[Password]  from dbo.Admin where Id=@LoginId
    
    if(@newPass<>@Confirm_Password)
    begin
     select 'Password did not match'
    end
    else if(@OldPass<>@Password)
    begin 
      
     select 'Incorrect Old Password'
    end
    else
    begin
     update dbo.Admin set [Password]=@newPass where Id=@LoginId
     
     select 'Password Changed Sucessfully'
    end
    
    
end




GO
/****** Object:  StoredProcedure [dbo].[changePassword_User]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[changePassword_User]
(
 @LoginId bigint = null,
 @Password nvarchar(500)=null,
 @Confirm_Password nvarchar(500)=null,
 @newPass nvarchar(500)=null
)
as
begin
    declare @OldPass nvarchar(500)
    
    select @OldPass=[Password]  from dbo.Login_Table where LoginId=@LoginId
    
    if(@newPass<>@Confirm_Password)
    begin
     select 'Password did not match'
    end
    else if(@OldPass<>@Password)
    begin 
      
     select 'Incorrect Old Password'
    end
    else
    begin
     update dbo.Login_Table set [Password]=@newPass where LoginId=@LoginId
     
     select 'Password Changed Sucessfully'
    end
    
    
end




GO
/****** Object:  StoredProcedure [dbo].[DeleteClassifiedCategory]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[DeleteClassifiedCategory]
(
@Catid varchar(50)
)
as
begin
Delete [dbo].[ClassifiedCategory] where [Catid]=@Catid
end



GO
/****** Object:  StoredProcedure [dbo].[DeleteMsg]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[DeleteMsg]
(
@Msg_id varchar(200),
@Deletedby varchar(50)
)
as
begin
if Exists(Select * from [dbo].[Message] where Msg_id=@Msg_id and Isnull(Deleted_By,'NA')<>'NA')
begin
Delete [dbo].[Message] where Msg_id=@Msg_id
end
else
begin
Update [dbo].[Message] set Deleted_By=@DeletedBy where Msg_id=@Msg_Id
end
end
GO
/****** Object:  StoredProcedure [dbo].[DeleteProperty]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[DeleteProperty]
(
 @PropertyId varchar(50)
 )
as
begin
begin transaction t
Delete dbo.Property_tbl where PropertyId=@PropertyId
Delete dbo.Property_Feature_Mapping where PropertyId=@PropertyId
Delete dbo.Property_Characteristic_Mapping where PropertyId=@PropertyId
Delete dbo.Propert_Age_Mapping where PropertyId=@PropertyId
Delete dbo.Property_Images where PropertyId=@PropertyId
Delete dbo.SavedProperty_tbl where PropertyId=@PropertyId
Commit transaction t
end




GO
/****** Object:  StoredProcedure [dbo].[DeleteSeller]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[DeleteSeller]
(
 @LoginId varchar(50)
 )
as
begin
begin transaction t
delete from Login_Table  where LoginId=@LoginId
delete from dbo.Profile_Info where LoginId =@LoginId
Commit transaction t
end




GO
/****** Object:  StoredProcedure [dbo].[ExecuteQueryPageWise]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [dbo].[ExecuteQueryPageWise]
(
@Qry nvarchar(max)='',
@OrderBy nvarchar(Max),
@ASCDESC varchar(20)='DESC',
@Page bigint=1,
@rowsPerPage  bigint=10
)
as
begin
declare @SQLQuery AS NVARCHAR(MAX)
declare @TOTALPage as bigint;
declare @TOTAL as bigint;
declare @ParaDefination nvarchar(Max)
declare @pageNum as bigint; 
set @pageNum=@Page; 

--select @TOTAL=COUNT(Restaurant_Id) from view_RestaurantList where Status=1 and Restaurant_Type=@Restaurant_Type and (Address like '%'+@Address+'%' or City like '%'+@Address+'%' or State like '%' + @Address + '%' or Country like '%' + @Address + '%');
set @ParaDefination='@TOTAL bigint=0 output'
--Set @SQLQuery='select @TOTAL=COUNT(Restaurant_Id) from view_RestaurantList where Status=1 and Restaurant_Type=@Restaurant_Type and  (Address like ''%'+@Address+'%'' or City like ''%'+@Address+'%'' or State like ''%' + @Address + '%'' or Country like ''%' + @Address + '%'')'+ @Filter;
set @SQLQuery ='Select @TOTAL=Count(*) from ('+@Qry+') A'

print @SQLQuery
EXECUTE sp_executesql @SQLQuery,@ParaDefination,@TOTAL output;
print @TOTAL

Set @SQLQuery='With SQLPaging As   ( 
    Select Top(@rowsPerPage * @pageNum) ROW_NUMBER() OVER (ORDER BY '+@OrderBy+' '+@ASCDESC+') 
    as RowNum, * 
    FROM ('+@Qry+') A' 
	
	set @SQLQuery=@SQLQuery+') select * from SQLPaging with (nolock) where RowNum > ((@pageNum - 1) * @rowsPerPage) order by RowNum ASC'
	set @ParaDefination='@rowsPerPage bigint,@pageNum bigint'		
	EXECUTE sp_executesql @SQLQuery,@ParaDefination,@rowsPerPage,@pageNum;

---------------------------------------------Calculate Pages-------------------------
set @TOTALPage=@TOTAL%@rowsPerPage
		if(@TOTALPage=0)
		begin
			set @TOTALPage=@TOTAL/@rowsPerPage

		end
		else
		begin
			set @TOTALPage=(@TOTAL/@rowsPerPage)+1
		
		end
			SELECT @TOTAL as Total,@TOTALPage as TotalPage
--------------------------------------------------------------------------------------

end




GO
/****** Object:  StoredProcedure [dbo].[ExecuteQueryPageWise_v3]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[ExecuteQueryPageWise_v3]
(
@Qry nvarchar(max)='',
@OrderBy nvarchar(Max),
@Page bigint=1,
@rowsPerPage  bigint=10
)
as
begin
declare @SQLQuery AS NVARCHAR(MAX)
declare @TOTALPage as bigint;
declare @TOTAL as bigint;
declare @ParaDefination nvarchar(Max)
declare @pageNum as bigint; 
set @pageNum=@Page; 

--select @TOTAL=COUNT(Restaurant_Id) from view_RestaurantList where Status=1 and Restaurant_Type=@Restaurant_Type and (Address like '%'+@Address+'%' or City like '%'+@Address+'%' or State like '%' + @Address + '%' or Country like '%' + @Address + '%');
set @ParaDefination='@TOTAL bigint=0 output'
--Set @SQLQuery='select @TOTAL=COUNT(Restaurant_Id) from view_RestaurantList where Status=1 and Restaurant_Type=@Restaurant_Type and  (Address like ''%'+@Address+'%'' or City like ''%'+@Address+'%'' or State like ''%' + @Address + '%'' or Country like ''%' + @Address + '%'')'+ @Filter;
set @SQLQuery ='Select @TOTAL=Count(*) from ('+@Qry+') A'

print @SQLQuery
EXECUTE sp_executesql @SQLQuery,@ParaDefination,@TOTAL output;
print @TOTAL

Set @SQLQuery='With SQLPaging As   ( 
    Select Top(@rowsPerPage * @pageNum) ROW_NUMBER() OVER (ORDER BY '+@OrderBy+') 
    as RowNum, * 
    FROM ('+@Qry+') A' 
	
	set @SQLQuery=@SQLQuery+') select * from SQLPaging with (nolock) where RowNum > ((@pageNum - 1) * @rowsPerPage) order by RowNum ASC'
	set @ParaDefination='@rowsPerPage bigint,@pageNum bigint'		
	EXECUTE sp_executesql @SQLQuery,@ParaDefination,@rowsPerPage,@pageNum;

---------------------------------------------Calculate Pages-------------------------
set @TOTALPage=@TOTAL%@rowsPerPage
		if(@TOTALPage=0)
		begin
			set @TOTALPage=@TOTAL/@rowsPerPage

		end
		else
		begin
			set @TOTALPage=(@TOTAL/@rowsPerPage)+1
		
		end
			SELECT @TOTAL as Total,@TOTALPage as TotalPage
--------------------------------------------------------------------------------------

end



GO
/****** Object:  StoredProcedure [dbo].[GetStampAmt]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetStampAmt]
(
@propertyAmt decimal(18,2)
)
as
begin
Select  A.AFrom, A.ATo, A.SRate, A.SecondHrate,A.RemainingAmt,Convert(decimal(18,2),((A.RemainingAmt*A.SRate)/100)) SRateAmt,Convert(decimal(18,2),((A.RemainingAmt*A.SecondHrate)/100))SHRateAmt from (Select *,(Case when Ato<=@propertyAmt then Ato-(Afrom-1)else @propertyAmt-(Afrom-1)end) RemainingAmt from StampDuty_tbl where AFrom<@propertyAmt) A
end




GO
/****** Object:  StoredProcedure [dbo].[insertUsrType]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[insertUsrType]
(
@Uid int,
@UserTypeName varchar(50)=null
)
as
begin
insert into dbo.User_Type(Uid,UserTypeName)
values(@Uid,@UserTypeName)
end




GO
/****** Object:  StoredProcedure [dbo].[PageWiseQuery_FullTxtSearch]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[PageWiseQuery_FullTxtSearch]
(
@Qry nvarchar(max)='',
@OrderBy nvarchar(Max),
@Page bigint=1,
@rowsPerPage  bigint=10,
@Search varchar(500)=null,
@SearchOnColumns varchar(500)=null,
@UniqueColId varchar(200)=null,
@Schema varchar(100)=null,
@TableName varchar(100)=null

)
as
begin
declare @SQLQuery AS NVARCHAR(MAX)
declare @TOTALPage as bigint;
declare @TOTAL as bigint;
declare @ParaDefination nvarchar(Max)
declare @pageNum as bigint; 
set @pageNum=@Page; 

if(isnull(@Search,'')<>'' and isnull(@SearchOnColumns,'')<>'' and isnull(@UniqueColId,'')<>'')
begin
set @Qry=@Qry+' and ['+@UniqueColId+'] in'+'('+dbo.MyFullTextSearchNew(@Search,@Schema,@TableName,@UniqueColId,@SearchOnColumns)+')'
end
--select @TOTAL=COUNT(Restaurant_Id) from view_RestaurantList where Status=1 and Restaurant_Type=@Restaurant_Type and (Address like '%'+@Address+'%' or City like '%'+@Address+'%' or State like '%' + @Address + '%' or Country like '%' + @Address + '%');
set @ParaDefination='@TOTAL bigint=0 output'
--Set @SQLQuery='select @TOTAL=COUNT(Restaurant_Id) from view_RestaurantList where Status=1 and Restaurant_Type=@Restaurant_Type and  (Address like ''%'+@Address+'%'' or City like ''%'+@Address+'%'' or State like ''%' + @Address + '%'' or Country like ''%' + @Address + '%'')'+ @Filter;


set @SQLQuery ='Select @TOTAL=Count(*) from ('+@Qry+') A'

print @SQLQuery
EXECUTE sp_executesql @SQLQuery,@ParaDefination,@TOTAL output;
print @TOTAL

Set @SQLQuery='With SQLPaging As   ( 
    Select Top(@rowsPerPage * @pageNum) ROW_NUMBER() OVER (ORDER BY '+@OrderBy+') 
    as RowNum, * 
    FROM ('+@Qry+') A' 
	
	set @SQLQuery=@SQLQuery+') select * from SQLPaging with (nolock) where RowNum > ((@pageNum - 1) * @rowsPerPage) order by RowNum ASC'
	set @ParaDefination='@rowsPerPage bigint,@pageNum bigint'		
	EXECUTE sp_executesql @SQLQuery,@ParaDefination,@rowsPerPage,@pageNum;

---------------------------------------------Calculate Pages-------------------------
set @TOTALPage=@TOTAL%@rowsPerPage
		if(@TOTALPage=0)
		begin
			set @TOTALPage=@TOTAL/@rowsPerPage

		end
		else
		begin
			set @TOTALPage=(@TOTAL/@rowsPerPage)+1
		
		end
			SELECT @TOTAL as Total,@TOTALPage as TotalPage
--------------------------------------------------------------------------------------

end



GO
/****** Object:  StoredProcedure [dbo].[PageWiseQuery_FullTxtSearch_Inquery]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[PageWiseQuery_FullTxtSearch_Inquery]
(
@Qry nvarchar(max)='',
@OrderBy nvarchar(Max),
@Page bigint=1,
@rowsPerPage  bigint=10,
@Search varchar(500)=null,
@SearchOnColumns varchar(500)=null,
@UniqueColId varchar(200)=null
--@Schema varchar(100)=null,
--@TableName varchar(100)=null
)
as
begin
declare @SQLQuery AS NVARCHAR(MAX)
declare @TOTALPage as bigint
declare @TOTAL as bigint
declare @ParaDefination nvarchar(Max)
declare @pageNum as bigint
declare @tmpqry as varchar(Max)
set @pageNum=@Page; 

set @tmpqry=@Qry


if(isnull(@Search,'')<>'' and isnull(@SearchOnColumns,'')<>'' and isnull(@UniqueColId,'')<>'')
begin

set @Qry=@Qry+' and ['+@UniqueColId+'] in'+'('+dbo.FullTextSearchInquery(@Search,@tmpqry,@UniqueColId,@SearchOnColumns)+')'
end
--select @TOTAL=COUNT(Restaurant_Id) from view_RestaurantList where Status=1 and Restaurant_Type=@Restaurant_Type and (Address like '%'+@Address+'%' or City like '%'+@Address+'%' or State like '%' + @Address + '%' or Country like '%' + @Address + '%');
set @ParaDefination='@TOTAL bigint=0 output'
--Set @SQLQuery='select @TOTAL=COUNT(Restaurant_Id) from view_RestaurantList where Status=1 and Restaurant_Type=@Restaurant_Type and  (Address like ''%'+@Address+'%'' or City like ''%'+@Address+'%'' or State like ''%' + @Address + '%'' or Country like ''%' + @Address + '%'')'+ @Filter;


set @SQLQuery ='Select @TOTAL=Count(*) from ('+@Qry+') A'

print @SQLQuery
EXECUTE sp_executesql @SQLQuery,@ParaDefination,@TOTAL output;
print @TOTAL

Set @SQLQuery='With SQLPaging As   ( 
    Select Top(@rowsPerPage * @pageNum) ROW_NUMBER() OVER (ORDER BY '+@OrderBy+') 
    as RowNum, * 
    FROM ('+@Qry+') A' 
	
	set @SQLQuery=@SQLQuery+') select * from SQLPaging with (nolock) where RowNum > ((@pageNum - 1) * @rowsPerPage) order by RowNum ASC'
	set @ParaDefination='@rowsPerPage bigint,@pageNum bigint'		
	EXECUTE sp_executesql @SQLQuery,@ParaDefination,@rowsPerPage,@pageNum;

---------------------------------------------Calculate Pages-------------------------
set @TOTALPage=@TOTAL%@rowsPerPage
		if(@TOTALPage=0)
		begin
			set @TOTALPage=@TOTAL/@rowsPerPage

		end
		else
		begin
			set @TOTALPage=(@TOTAL/@rowsPerPage)+1
		
		end
			SELECT @TOTAL as Total,@TOTALPage as TotalPage
--------------------------------------------------------------------------------------

end



GO
/****** Object:  StoredProcedure [dbo].[Ptype_Pfor_Mapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Ptype_Pfor_Mapping]
(
@PropertyTypeId varchar(50),
@PropertyFor  nvarchar(100)
)
as
begin
if(isnull(@PropertyFor,'')<>'')
begin
Delete [dbo].[PropertyType_Pfor_mapping] where PropertyTypeId=@PropertyTypeId
insert into [dbo].PropertyType_Pfor_mapping(PropertyTypeId, PropertyFor) select @PropertyTypeId,item from dbo.Splitmaster(@PropertyFor,',') where isnull(item,'')<>''
end
end
GO
/****** Object:  StoredProcedure [dbo].[Reset_Password]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Reset_Password]
(
 @UserId nvarchar(50),
 @Password nvarchar(50)=null

)
as
begin
update dbo.Login_Table set [Password]=@Password where [UserId]=@UserId 
end



GO
/****** Object:  StoredProcedure [dbo].[Save_Property]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Save_Property]
(

@LoginId	bigint=null,
@PropertyId	varchar(50)=null	
)
as
begin
if Not Exists(Select * from dbo.SavedProperty_tbl where LoginId=@LoginId and PropertyId=@PropertyId)
insert into dbo.SavedProperty_tbl(LoginId, PropertyId)values(@LoginId,@PropertyId)
end

GO
/****** Object:  StoredProcedure [dbo].[SaveClassifiedCategory]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SaveClassifiedCategory]
(
@Catid varchar(50),
@CategoryName nvarchar(50) = null,
@Image varchar(100) = null
)
as
begin
if Exists(Select * from ClassifiedCategory where [Catid]=@Catid)
begin
update ClassifiedCategory set [Catid]=@Catid, [CategoryName]=@CategoryName,[Image]=@Image
where [Catid] = @Catid
end
else
begin
insert into ClassifiedCategory ([Catid],[CategoryName],[Image],[IsActive],EntryDate)values(@Catid,@CategoryName,@Image,1,GetDate())
end
end
GO
/****** Object:  StoredProcedure [dbo].[SaveProperty]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SaveProperty]
(
@PropertyId varchar(50),
@PropertyTitle nvarchar(200)=null,
@PropertyFor nvarchar(50) = null,
@PropertyTypeId varchar(50) = null,
@FrontImage varchar(200) = null,
@Price decimal = null,
@PriceUnit varchar(50) = null,
@Area decimal(18,2) = null,
@AreaUnit varchar(50) = null,
@PAgeId varchar(50) = null,
@Description nvarchar(Max) = null,
@Address varchar(500) = null,
@City nvarchar(100) = null,
@State nvarchar(50) = null,
@PostCode nvarchar(50) = null,
@Latitude float = null,
@Longitude float = null,
@Video varchar(50) = null,
@Contact varchar(50) = null,
@CreatedBy varchar(50) = null,
@FurnishedStatus nvarchar(50) = null,
@Features nvarchar(MAX)=null,
@PropertyImages varchar(MAx)=null,
@MLSNumber nvarchar(50)=null,
@LOTArea decimal(18,2)=null,
@LOTAreaUnit varchar(50)=null,
@YearBuilt int=null
)
as
begin

if Not Exists(Select * from  Property_tbl where PropertyId=@PropertyId)
begin
insert into Property_tbl
([PropertyId],[Property_Title],[PropertyFor],[PropertyTypeId],[FrontImage],[Price],[PriceUnit],[Area],[AreaUnit],[PAgeId],[Description],[Address],[City],[State],[PostCode],[Latitude],[Longitude],[Video],[Contact],[CreatedBy],[CreatedOn],[FurnishedStatus],Property_Status,[Featured],[IsSold],MLSNumber,LOTArea,LOTAreaUnit,YearBuilt)
values
(@PropertyId,@PropertyTitle,@PropertyFor,@PropertyTypeId,@FrontImage,@Price,@PriceUnit,@Area,@AreaUnit,@PAgeId,@Description,@Address,@City,@State,@PostCode,@Latitude,@Longitude,@Video,@Contact,@CreatedBy,GETDATE(),@FurnishedStatus,0,'True','False',@MLSNumber,@LOTArea,@LOTAreaUnit,@YearBuilt)
if(@Features<>'')
begin
Delete dbo.Property_Feature_Mapping where PropertyId=@PropertyId
Insert into dbo.Property_Feature_Mapping Select  Substring(Item, 1,Charindex('#', Item)-1) , @PropertyId,Substring(Item, Charindex('#', Item)+1, LEN(Item)) from dbo.Splitmaster(@Features,',')
end
if(@PropertyImages<>'')
begin
insert into [dbo].[Property_Images](PropertyId, PrpertyImage)select @PropertyId,item from dbo.Splitmaster(@PropertyImages,',')
end
end
end
GO
/****** Object:  StoredProcedure [dbo].[SavePTypeFeatureMapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SavePTypeFeatureMapping]
(
@PropertyTypeId varchar(50),
@features nvarchar(Max)
)
as
begin
Delete [dbo].[ProprtyType_Feature_Mapping] where [PropertyTypeId]=@PropertyTypeId
insert into [dbo].[ProprtyType_Feature_Mapping](PropertyTypeId,FeatureId) select @PropertyTypeId,item from dbo.Splitmaster(@features,',')

end
GO
/****** Object:  StoredProcedure [dbo].[SaveRecentSearch]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SaveRecentSearch]
(
@UniqueId	nvarchar(500)	,
@SearchId	varchar(50)	,
@SearchType	nvarchar(50)	,
@SearchName	nvarchar(500)
)
as
begin

if not Exists(Select * from dbo.RecentSearchTbl where UniqueId=@UniqueId and SearchId=@SearchId and SearchType=@SearchType)
begin
insert into dbo.RecentSearchTbl( UniqueId, SearchId, SearchType, SearchName)values(@UniqueId, @SearchId, @SearchType, @SearchName)
end

end
GO
/****** Object:  StoredProcedure [dbo].[SaveSearch]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SaveSearch]
(
@uniqueId	nvarchar(500)	,
@Location	nvarchar(500)	,
@MinPrice	bigint	,
@MaxPrice	bigint	,
@MinBed	int	
)
as
begin
if Exists(Select uniqueid from dbo.Search_tbl where uniqueId=@uniqueId)
begin
Update dbo.Search_tbl set  Location=@Location, MinPrice=@MinPrice, MaxPrice=@MaxPrice, MinBed=@MinBed where uniqueId=@uniqueId
end
else
begin 
insert into dbo.Search_tbl(uniqueId, Location, MinPrice, MaxPrice, MinBed)values(@uniqueId, @Location, @MinPrice, @MaxPrice, @MinBed)
end

end
GO
/****** Object:  StoredProcedure [dbo].[sp_Admin_login]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[sp_Admin_login]
@username nvarchar(50) ,
@password  nvarchar(50)
as 
begin 
 select * from dbo.Admin where username=@username and password=@password
end




GO
/****** Object:  StoredProcedure [dbo].[sp_FindStringInTable]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE PROCEDURE [dbo].[sp_FindStringInTable] @stringToFind VARCHAR(100), @schema sysname, @table sysname 
AS

BEGIN TRY
   DECLARE @sqlCommand varchar(max) = 'SELECT * FROM [' + @schema + '].[' + @table + '] WHERE ' 
	   
   SELECT @sqlCommand = @sqlCommand + '[' + COLUMN_NAME + '] LIKE ''' + @stringToFind + ''' OR '
   FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE TABLE_SCHEMA = @schema
   AND TABLE_NAME = @table 
   AND DATA_TYPE IN ('char','nchar','ntext','nvarchar','text','varchar')

   SET @sqlCommand = left(@sqlCommand,len(@sqlCommand)-3)
   EXEC (@sqlCommand)
   PRINT @sqlCommand
END TRY

BEGIN CATCH 
   PRINT 'There was an error. Check to make sure object exists.'
   PRINT error_message()
END CATCH



GO
/****** Object:  StoredProcedure [dbo].[spp_addArea]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_addArea]
( 
@Area nvarchar(50)
)
AS
BEGIN
	insert into dbo.Area_tbl (Area)
     values (@Area)
  END
GO
/****** Object:  StoredProcedure [dbo].[spp_addSlide]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_addSlide]
(
 @Slide_Name nvarchar(50),
 @Title nvarchar(250),
 @Image nvarchar(500)
)
as
begin
 insert into dbo.Slide (Slide_Name, Title, [Image]) values (@Slide_Name,@Title,@Image)
end
GO
/****** Object:  StoredProcedure [dbo].[spp_changePassword]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_changePassword] 
(
 @username nvarchar(50),  
 @OldPassword nvarchar(50),
 @NewPass1 nvarchar(50),
 @NewPass2 nvarchar(50)
)
as
begin
    declare @OldPass nvarchar(50)
    
    select @OldPass=Password  from dbo.Admin where username=@username
    if(@OldPass<>@OldPassword)
    begin
     select 'Enter correct old password'
    end
    if(@NewPass1<>@NewPass2)
    begin
     select 'Password did not match'
    end
    else if(@OldPass<>@OldPassword)
    begin 
      
     select 'Incorrect Old Password'
    end
    else
    begin
     update dbo.Admin set password=@NewPass1 where username=@username
     select 'Password Changed Sucessfully'
    end
end




GO
/****** Object:  StoredProcedure [dbo].[spp_Characteristic]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_Characteristic]
( 
@Characteristic nvarchar(50)
)
AS
BEGIN

	insert into dbo.PropertyCharacteristics (Characteristic)
     values (@Characteristic)
  END
GO
/****** Object:  StoredProcedure [dbo].[spp_delete_agent]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_delete_agent]
(
@UserId varchar(50)
)
as
begin
delete [dbo].[Profile_Info] where [Profile_Id]=@UserId
delete [dbo].[Login_Table] where [UserId]=@UserId
delete [dbo].[Property_tbl]  where [CreatedBy]=@UserId
delete [dbo].[Property_Images] where Propertyid in (SELECT PropertyId From [dbo].[Property_tbl] p WHERE [CreatedBy]=@UserId)
end
GO
/****** Object:  StoredProcedure [dbo].[spp_Delete_Agent_Pic]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[spp_Delete_Agent_Pic]
(
@PhotoId varchar(50)
)
as
begin
delete from [dbo].[Agent_Picture] where [PhotoId]=@PhotoId
end



GO
/****** Object:  StoredProcedure [dbo].[spp_Delete_Agent_video]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[spp_Delete_Agent_video]
(
@VideoId varchar(50)
)
as
begin
Delete from [dbo].[Agent_Video] where [VideoId]=@VideoId
end



GO
/****** Object:  StoredProcedure [dbo].[spp_Delete_Classifiedtbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[spp_Delete_Classifiedtbl]
(
@ClassifiedId varchar(50)
)
as
begin
Delete from [dbo].[ClassifiedPostImg_tbl] where [ClassifiedId]=@ClassifiedId
Delete from [dbo].[ClassifiedFeature_tbl] where [ClassifiedId]=@ClassifiedId
Delete from [dbo].[ClassifiedAds_tbl] where [ClassifiedId]=@ClassifiedId
end



GO
/****** Object:  StoredProcedure [dbo].[spp_Delete_Property_video]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[spp_Delete_Property_video]
(
@VideoId varchar(50)
)
as
begin
Delete from [dbo].[Property_video] where [VideoId]=@VideoId 
end



GO
/****** Object:  StoredProcedure [dbo].[spp_Delete_Propertytbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_Delete_Propertytbl]
(
@PropertyId varchar(50)=null
)
as
begin
Delete [dbo].[Property_tbl] where [PropertyId]=@PropertyId
Delete [dbo].[Property_Images] where [PropertyId]=@PropertyId
Delete [dbo].[Property_Feature_Mapping] where [PropertyId]=@PropertyId
end



GO
/****** Object:  StoredProcedure [dbo].[spp_Delete_propertytyp]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_Delete_propertytyp]
(
@PropertyTypeId varchar(50)
)
as
begin
delete from [dbo].[PropertyType_tbl] where [PropertyTypeId]=@PropertyTypeId
end



GO
/****** Object:  StoredProcedure [dbo].[spp_delete_sociallink]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[spp_delete_sociallink]
(
@SMID varchar(50),
@UserId nvarchar(200) = null
)
as
begin
delete [dbo].[SociallinkMapping_tbl] where [SMID]=@SMID 
end
GO
/****** Object:  StoredProcedure [dbo].[spp_Delete_Testimonial]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[spp_Delete_Testimonial]
(
@Tid varchar(50)
)
as
begin
Delete from [dbo].[Testimonial] where [Tid] = @Tid
end



GO
/****** Object:  StoredProcedure [dbo].[spp_delete_user]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[spp_delete_user]
(
@UserId varchar(50)
)
as
begin
delete from  [dbo].[Login_Table] where [UserId]=@UserId
delete from [dbo].[Profile_Info] where [Profile_Id]=@UserId
end
GO
/****** Object:  StoredProcedure [dbo].[spp_deleteSlide]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[spp_deleteSlide]
(
 @id int
)
as
begin
 delete from dbo.Slide where id=@id
end

ROLLBACK




GO
/****** Object:  StoredProcedure [dbo].[spp_Feature]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_Feature]
( 
@FeatureId varchar(50),
@FeatureName nvarchar(50),
@FeatureType	nvarchar(50)	,
@FeatureCatId varchar(50)
)
AS
BEGIN
	insert into dbo.FeatureMaster (FeatureName,FeatureId,FeatureType,FeatureCatId,IsDefault)
     values (@FeatureName,@FeatureId,@FeatureType,@FeatureCatId,0)
END
GO
/****** Object:  StoredProcedure [dbo].[spp_getLogin]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_getLogin]
(
 @EmailId nvarchar(50),
 @Password nvarchar(50)
)
as
begin
if exists(select * from [dbo].[Login_Table] where   [EmailId] COLLATE SQL_Latin1_General_CP1_CI_AS=@EmailId and [Password] COLLATE SQL_Latin1_General_CP1_CI_AS=@Password)
begin
update [dbo].[Login_Table] set [Last_visited]=GETDATE() where   [EmailId] COLLATE SQL_Latin1_General_CP1_CI_AS=@EmailId and [Password] COLLATE SQL_Latin1_General_CP1_CI_AS=@Password
 end
select * from [dbo].[Login_Table] where   [EmailId] COLLATE SQL_Latin1_General_CP1_CI_AS=@EmailId and [Password] COLLATE SQL_Latin1_General_CP1_CI_AS=@Password
end



GO
/****** Object:  StoredProcedure [dbo].[spp_getMessage]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_getMessage]
(
@Msg_From_User_Id varchar(100) = null,
@Msg_To_User_Id varchar(100) = null
)
as
begin
Select * from 
(select * from dbo.[Message] where Msg_From_User_Id=@Msg_From_User_Id and Msg_To_User_Id=@Msg_To_User_Id and  isnull(Deleted_By,'NA')<>@Msg_To_User_Id
 union 
 select * from dbo.[Message] where Msg_From_User_Id=@Msg_To_User_Id and Msg_To_User_Id=@Msg_From_User_Id and  isnull(Deleted_By,'NA')<>@Msg_To_User_Id
 )A 
  order by A.Msg_Date ASc 
end
GO
/****** Object:  StoredProcedure [dbo].[Spp_Google_Login]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Spp_Google_Login]
(
@Uid   int=null,
@UserId	nvarchar(200)=null,
@EmailId	nvarchar(500),
@FirstName	nvarchar(100)=null,
@LastName	nvarchar(100)=null,
@googleId varchar(100)
)
as
begin
declare @Status	bit	
if Exists(Select * from Login_Table where EmailId=@EmailId)
begin
select * from Login_Table where EmailId=@EmailId
end
else 
begin
begin transaction t
set @Status=1
insert into Login_Table( Uid, UserId, EmailId, FirstName, LastName, Status,[Email_verified],googleId)values(@Uid, @UserId, @EmailId, @FirstName, @LastName, @Status,1,@googleId)
insert Into dbo.Profile_Info(Profile_Id)values(@UserId)
if(@@Error>0)
begin
Rollback transaction t
end
else
begin
Commit transaction t
end

select * from Login_Table where EmailId=@EmailId

end
end



GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Ads_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Ads_tbl]

(

@AdId varchar(50),

@Ad_Image varchar(50) = null,

@Ad_Description nvarchar(10) = null,

@City nvarchar(50) = null,

@ZipCode nvarchar(50) = null,

@Link nvarchar(500) = null

)

as

begin

If exists(select * from [dbo].[Ads_tbl] where [AdId]=@AdId)

begin

update Ads_tbl set  [Ad_Image]=@Ad_Image, [Ad_Description]=@Ad_Description, [City]=@City, [ZipCode]=@ZipCode,[Link]=@Link

where [AdId] = @AdId

end

else

begin

insert into Ads_tbl

([AdId],[Ad_Image],[Ad_Description],[City],[ZipCode],[Link],[EntryDate],[Status])

values

(@AdId,@Ad_Image,@Ad_Description,@City,@ZipCode,@Link,GETDATE(),1)

end

end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Agent_Picture]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Agent_Picture]
(
@PhotoId varchar(50),
@ProfileId varchar(50) = null,
@Photo_Title varchar(200) = null,
@Photo varchar(50) = null
)
as
begin
insert into Agent_Picture
([PhotoId],[Profile_Id],[Photo_Title],[Photo],[Photo_Entrydate])
values
(@PhotoId,@ProfileId,@Photo_Title,@Photo,GETDATE())
end



GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Agent_Review_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Agent_Review_tbl]
(
@Rating int = null,
@ReviewText nvarchar(MAX) = null,
@AgentId varchar(50) = null,
@UserId varchar(50) = null
)
as
begin
If Exists(Select * from [dbo].[Agent_Review_tbl] where [UserId]=@UserId and [AgentId]=@AgentId)
begin
update Agent_Review_tbl set [Rating]=@Rating, [ReviewText]=@ReviewText, [AgentId]=@AgentId, [UserId]=@UserId
where [UserId]=@UserId and [AgentId]=@AgentId
end
else
begin
insert into Agent_Review_tbl
([Rating],[ReviewText],[AgentId],[UserId],[ReviewDate])
values
(@Rating,@ReviewText,@AgentId,@UserId,GETDATE())
end
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Agent_Video]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Agent_Video]
(
@VideoId varchar(50),
@ProfileId varchar(50)=null,
@Video_Title nvarchar(50) = null,
@File_Type nvarchar(20) = null,
@Video varchar(50) = null
)
as
begin
insert into Agent_Video
([VideoId],[Profile_Id],[Video_Title],[File_Type],[Video],[Video_Entrydate])
values
(@VideoId,@ProfileId,@Video_Title,@File_Type,@Video,GETDATE())
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_AgentContact_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_AgentContact_tbl]
(
@AgentContact_Id varchar(50) = null,
@Name nvarchar(100) = null,
@Phone varchar(20) = null,
@Email nvarchar(100) = null,
@Message nvarchar(500) = null,
@PropertyId varchar(50) = null,
@Profile_Id varchar(50)=null
)
as
begin
insert into AgentContact_tbl
([AgentContact_Id],[Name],[Phone],[Email],[Message],[PropertyId],[Profile_Id],[Entry_Date],[Status])
values
(@AgentContact_Id,@Name,@Phone,@Email,@Message,@PropertyId,@Profile_Id,GETDATE(),'True')
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Classified_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Classified_tbl]
(
@ClassifiedId varchar(50),
@Info nvarchar(MAX) = null
)
as
begin
insert into Classified_tbl
([ClassifiedId],[Info],[Entry_date],[Status])
values
(@ClassifiedId,@Info,GETDATE(),1)
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_ClassifiedAds_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_ClassifiedAds_tbl]

(

@ClassifiedId varchar(50),

@Title nvarchar(100) = null,

@Pay_Type varchar(10) = null,

@Amount decimal = null,

@Image varchar(50)=null,

@Description nvarchar(Max) = null,

@Contact_Name nvarchar(100) = null,

@Contact_Email nvarchar(100) = null,

@Contact_Phone varchar(20) = null,

@Contact_location nvarchar(100) = null,

@Catid varchar(50)= null,

@Latitude float = null,

@Longitude float = null

)

as

begin

insert into ClassifiedAds_tbl

([ClassifiedId],[Title],[Pay_Type],[Amount],[Image],[Description],[Contact_Name],[Contact_Email],[Contact_Phone],[Contact_location],[ClassifiedEntry_Date],[ClassifiedStatus],Catid,[Latitude],[Longitude])

values

(@ClassifiedId,@Title,@Pay_Type,@Amount,@Image,@Description,@Contact_Name,@Contact_Email,@Contact_Phone,@Contact_location,GETDATE(),1,@Catid,@Latitude,@Longitude)

end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_ClassifiedFeature_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_ClassifiedFeature_tbl]
(
@CFeatureid varchar(50),
@ClassifiedId varchar(50) = null,
@Feature_Detail nvarchar(100) = null,
@Feature_Value nvarchar(100) = null
)
as
begin
insert into ClassifiedFeature_tbl
([CFeatureid],[ClassifiedId],[Feature_Detail],[Feature_Value],[FeatureEntry_Date],[Feature_Status])
values
(@CFeatureid,@ClassifiedId,@Feature_Detail,@Feature_Value,GetDate(),1)
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_ClassifiedPostImg_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_ClassifiedPostImg_tbl]
(
@ClassifiedId varchar(50) = null,
@Post_Images varchar(MAX) = null
)
as
begin
If exists(Select * from [dbo].[ClassifiedPostImg_tbl] where [ClassifiedId]=@ClassifiedId)
begin
--Delete from [dbo].[ClassifiedPostImg_tbl] where [ClassifiedId]=@ClassifiedId
insert into [dbo].[ClassifiedPostImg_tbl](ClassifiedId, Post_Images)select @ClassifiedId,item from dbo.Splitmaster(@Post_Images,',')
end
else
begin
insert into [dbo].[ClassifiedPostImg_tbl](ClassifiedId, Post_Images)select @ClassifiedId,item from dbo.Splitmaster(@Post_Images,',')
end
end



GO
/****** Object:  StoredProcedure [dbo].[spp_Insert_CMS_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_Insert_CMS_tbl]
(
@Id int,
@Image varchar(50)=null,
@Title nvarchar(100)=null,
@Sub_Title nvarchar(100)=null
)
as
begin
update [dbo].[CMS_tbl] set [Image]=@Image,[Title]=@Title,[Sub_Title]=@Sub_Title where Id =@Id
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Contact_Tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Contact_Tbl]
(
@ContactId varchar(50) = null,
@Name nvarchar(50) = null,
@Email nvarchar(50) = null,
@Contact nvarchar(20) = null,
@Subject nvarchar(100) = null,
@Message nvarchar(500) = null
)
as
begin
insert into Contact_Tbl
([ContactId],[Name],[Email],[Contact],[Subject],[Message],[Entrydate],[Status])
values
(@ContactId,@Name,@Email,@Contact,@Subject,@Message,GETDATE(),1)
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Favourite_Property]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Favourite_Property]
(
@Profile_Id varchar(50) = null,
@PropertyId varchar(50) = null
)
as
begin
If  Exists (Select * from [dbo].[Favourite_Property] where [Profile_Id]=@Profile_Id and [PropertyId]=@PropertyId )
begin
Delete from [dbo].[Favourite_Property] where [Profile_Id]=@Profile_Id and [PropertyId]=@PropertyId
end
else
begin
insert into Favourite_Property
([Profile_Id],[PropertyId],[Entrydate])
values
(@Profile_Id,@PropertyId,GETDATE())
end
end



GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Holiday_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Holiday_tbl]
(
@HolidayId varchar(50),
@Holiday_Name nvarchar(100) = null,
@Holiday_On varchar(20) = null,
@Holiday_Date date = null,
@Start_Date date = null,
@End_Date date = null,
@About_Holiday nvarchar(200) = null
)
as
begin
If exists (Select [HolidayId] from [dbo].[Holiday_tbl] where [HolidayId]=@HolidayId)
begin
update Holiday_tbl set [Holiday_Name]=@Holiday_Name, [Holiday_On]=@Holiday_On, [Holiday_Date]=@Holiday_Date, [Start_Date]=@Start_Date, [End_Date]=@End_Date, [About_Holiday]=@About_Holiday
where [HolidayId] = @HolidayId
end
else
begin
insert into Holiday_tbl
([HolidayId],[Holiday_Name],[Holiday_On],[Holiday_Date],[Start_Date],[End_Date],[About_Holiday],[Entry_Date])
values
(@HolidayId,@Holiday_Name,@Holiday_On,@Holiday_Date,@Start_Date,@End_Date,@About_Holiday,GETDATE())
end
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Notes_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Notes_tbl]
(
@Id varchar(50),
@NoteText nvarchar(Max) = null,
@IsPublic bit = null,
@PropertyId	varchar(50)	=null,
@CreatedBy	varchar(50)	=null,
@Position	nvarchar(50)	=null,
@posX	varchar(50)	=null,
@PosY	varchar(50)	=null
)
as
begin
if Exists(Select Id from Notes_tbl where id=@Id )
begin
update Notes_tbl set  [NoteText]=@NoteText,Position=@Position,posX=@posX,PosY=@PosY
where [Id] = @Id
end
else
begin
insert into Notes_tbl
([Id],[NoteText],[IsPublic],PropertyId,CreatedBy,CreatedDate,Position,posX,PosY)
values
(@Id,@NoteText,@IsPublic,@PropertyId,@CreatedBy,GetDate(),@Position,@posX,@PosY)
end

end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_PriceHistory_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_PriceHistory_tbl]
(
@PriceId varchar(50),
@Date datetime = null,
@Event nvarchar(50) = null,
@Price decimal(18,3) = null,
@Price_Sqft decimal(18,3) = null,
@Source nvarchar(50) = null,
@PropertyId varchar(50) = null
)
as
begin
insert into PriceHistory_tbl
([PriceId],[Date],[Event],[Price],[Price_Sqft],[Source],[PropertyId],[Entry_Date])
values
(@PriceId,@Date,@Event,@Price,@Price_Sqft,@Source,@PropertyId,GETDATE())
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Property_video]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Property_video]
(
@VideoId varchar(50),
@PropertyId varchar(50) = null,
@Video_Title nvarchar(100) = null,
@File_Type nvarchar(20) = null,
@Video varchar(50) = null
)
as
begin
insert into Property_video
([VideoId],[PropertyId],[Video_Title],[File_Type],[Video],[Video_Entrydate])
values
(@VideoId,@PropertyId,@Video_Title,@File_Type,@Video,GETDATE())
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Social]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[spp_insert_Social]
(
@Id bigint,
@Facebook nvarchar(100) = null,
@Twitter nvarchar(100) = null,
@Instagram nvarchar(100) = null,
@Googleplus nvarchar(100) = null,
@Youtube nvarchar(100) = null,
@Linkedin nvarchar(100) = null
)
as
begin
update Social set [Facebook]=@Facebook, [Twitter]=@Twitter, [Instagram]=@Instagram, [Googleplus]=@Googleplus, [Youtube]=@Youtube, [Linkedin]=@Linkedin
where [Id] = @Id
end



GO
/****** Object:  StoredProcedure [dbo].[spp_insert_SociallinkMapping_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_SociallinkMapping_tbl]



(


@SMID varchar(50),

@SocialId bigint = null,
@UserId nvarchar(200) = null,
@Social_link nvarchar(200) = null
)



as

begin



insert into SociallinkMapping_tbl



(SMID ,[SocialId],[UserId],[Social_link],[Entrydate])



values



(@SMID,@SocialId,@UserId,@Social_link,GETDATE())



end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_Subscription_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_Subscription_tbl]
(
@SubscripId varchar(50) = null,
@Email nvarchar(100) = null
)
as
begin
insert into Subscription_tbl
([SubscripId],[Email],[IsSuscribed],[Entrydate])
values
(@SubscripId,@Email,0,GETDATE())
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insert_TaxHistory_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insert_TaxHistory_tbl]
(
@TaxId varchar(50),
@Year bigint=null,
@PropertyTax decimal = null,
@PTax_Changes decimal = null,
@TaxAssessmnt decimal = null,
@TaxAssessmnt_Changes decimal = null,
@PropertyId varchar(50) = null
)
as
begin
insert into TaxHistory_tbl
([TaxId],[Year],[PropertyTax],[PTax_Changes],[TaxAssessmnt],[TaxAssessmnt_Changes],[PropertyId],[Entry_Date])
values
(@TaxId,@Year,@PropertyTax,@PTax_Changes,@TaxAssessmnt,@TaxAssessmnt_Changes,@PropertyId,GETDATE())
end



GO
/****** Object:  StoredProcedure [dbo].[spp_insert_tblCMS]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[spp_insert_tblCMS]

(

@Id int,

@Page_Name nvarchar(50) = null,

@Page_Title nvarchar(50) = null,

@Page_Heading nvarchar(MAX) = null,

@Page_Content nvarchar(MAX) = null

)

as

begin

update tblCMS set  [Page_Name]=@Page_Name, [Page_Title]=@Page_Title, [Page_Heading]=@Page_Heading, [Page_Content]=@Page_Content

where [Id] = @Id

end
GO
/****** Object:  StoredProcedure [dbo].[spp_insertArrangeViewing]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[spp_insertArrangeViewing]
(
@Title nvarchar(50) = null,
@Name nvarchar(100) = null,
@EmailId nvarchar(500) = null,
@Primary_Telephone nvarchar(50) = null,
@Work_Telephone nvarchar(50) = null,
@MobileNo nvarchar(50) = null,
@Viewing_Date date = null,
@Time_of_Day nvarchar(50) = null,
@Other_Requirement nvarchar(500) = null,
@UserId nvarchar(200) = null,
@PropertyId  varchar(50) = null
)
as
begin
insert into dbo.Arrange_Viewing
([Title],[Name],[EmailId],[Primary_Telephone],[Work_Telephone],[MobileNo],[Viewing_Date],[Time_of_Day],[Other_Requirement],[UserId],[PropertyId])
values
(@Title,@Name,@EmailId,@Primary_Telephone,@Work_Telephone,@MobileNo,@Viewing_Date,@Time_of_Day,@Other_Requirement,@UserId,@PropertyId)
end




GO
/****** Object:  StoredProcedure [dbo].[spp_insertGallery]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insertGallery]
(
@id nvarchar(50),
@Title nvarchar(50),
@Image nvarchar(50)
)
as
begin
insert into Gallery
([id],[Title],[Image])
values
(@id,@Title,@Image)
end
GO
/****** Object:  StoredProcedure [dbo].[spp_insertProperty_Photo]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[spp_insertProperty_Photo]
(
@PropertyId varchar(50),
@PrpertyImage nvarchar(max) = null
)
as
begin
insert into Property_Images
([PropertyId],[PrpertyImage])
values
(@PropertyId,@PrpertyImage)
end




GO
/****** Object:  StoredProcedure [dbo].[spp_insertTestimonial]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_insertTestimonial]
(
@Tid varchar(50),
@Name nvarchar(100) = null,
@Designation nvarchar(50) = null,
@Comment nvarchar(200) = null,
@Photo varchar(50) = null
)
as
begin
insert into Testimonial
([Tid],[Name],[Designation],[Comment],[Photo],[Status],[Entry_Date])
values
(@Tid,@Name,@Designation,@Comment,@Photo,'TRUE',GETDATE())
end
GO
/****** Object:  StoredProcedure [dbo].[spp_login_tbl__info_Info]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_login_tbl__info_Info]
(

@Profile_Id nvarchar(50)=null,
@Uid int ,
@LoginId	bigint=0,
@FirstName nvarchar(100) = null,
@LastName nvarchar(100) = null,
@ContactNo varchar(12) = null,
@Address nvarchar(500) = null,
@City nvarchar(50) = null,
@State nvarchar(50) = null,
@Country nvarchar(50) = null,
@Zip nvarchar(10) = null,
@Photo nvarchar(500) = null,
@UserId nvarchar(200) = null,
@DOB date = null,
@Gender varchar(50) = null,
@EmailId nvarchar(500)=null,
@Password  nvarchar(500)=null,
@Status bit = null,
@CreatedBy nvarchar(50)=null
)
as
begin
if (Exists(Select LoginId from  Login_Table where [LoginId]=@LoginId ))
begin
begin Transaction t
begin try 
update Profile_Info set Profile_Id=@Profile_Id, [LoginId]=@LoginId, [ContactNo]=@ContactNo, [Address]=@Address, [City]=@City, [State]=@State, [Country]=@Country, [Zip]=@Zip, [Photo]=@Photo, [DOB]=@DOB, [Gender]=@Gender,[Last_Modified_Date]=GETDATE(),[CreatedBy]=@CreatedBy
where [LoginId]=@LoginId
Update Login_Table Set FirstName=@FirstName,LastName=@LastName,EmailId=@EmailId,[Password]=@Password,UserId=@UserId where LoginId=@LoginId
commit transaction t
end try
begin catch
Rollback transaction t
end catch

end
else
begin
insert into Login_Table( Uid, UserId, EmailId, FirstName, LastName,[Password], Status)values(@Uid, @UserId, @EmailId, @FirstName, @LastName,@Password, @Status)
Select @LoginId=ISNULL(MAX(LoginId),0) from dbo.Login_Table 
insert into dbo.Profile_Info (Profile_Id,[LoginId],[ContactNo],[Address],[City],[State],[Country],[Zip],[Photo],[DOB],[Gender],[Entry_Date],[Last_Modified_Date],[CreatedBy])
values(@Profile_Id,@LoginId,@ContactNo,@Address,@City,@State,@Country,@Zip,@Photo,@DOB,@Gender,GETDATE(),GETDATE(),@CreatedBy)
end
end




GO
/****** Object:  StoredProcedure [dbo].[spp_PropertyAge]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_PropertyAge]
( 
@PropertyAge nvarchar(50)
)
AS
BEGIN

	insert into dbo.PropertyAgeMaster_tbl (PropertyAge)
     values (@PropertyAge)
  END
GO
/****** Object:  StoredProcedure [dbo].[spp_PropertyType_tbl_Add]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_PropertyType_tbl_Add]
( 
@PropertyTypeId varchar(50),
@PropertyType nvarchar(50),
@PropertyTyp_Image nvarchar(50)=null ,
@PropertyTypeCode nvarchar(50)=null
)
AS
BEGIN
insert into dbo.PropertyType_tbl (PropertyTypeId,PropertyType,[PropertyTyp_Image],PropertyTypeCode) values (@PropertyTypeId,@PropertyType,@PropertyTyp_Image,@PropertyTypeCode)
END
GO
/****** Object:  StoredProcedure [dbo].[spp_propertytype_update]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[spp_propertytype_update] 

@PropertyTypeId varchar(50),

@PropertyType nvarchar(50)=null,

@PropertyTyp_Image varchar(50)=null,

@PropertyTypeCode nvarchar(50)=null

as 

begin 

   update  PropertyType_tbl  set PropertyType=@PropertyType,PropertyTypeCode=@PropertyTypeCode,

   PropertyTyp_Image=@PropertyTyp_Image where PropertyTypeId=@PropertyTypeId

end
GO
/****** Object:  StoredProcedure [dbo].[spp_RegisterUsingFacebook]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[spp_RegisterUsingFacebook]
(
@Uid   int=null,
@UserId	nvarchar(200)=null,
@EmailId	nvarchar(500),
@FirstName	nvarchar(100)=null,
@LastName	nvarchar(100)=null,
@googleId varchar(100)
)
as

begin
declare @Status	bit	
if Exists(Select * from Login_Table where EmailId=@EmailId)
begin
select * from Login_Table where EmailId=@EmailId
end
else 
begin
begin transaction t
set @Status=1
insert into Login_Table( Uid, UserId, EmailId, FirstName, LastName,[Status],[Email_verified],[googleId])
values
(@Uid, @UserId, @EmailId, @FirstName, @LastName, @Status,1,@googleId)
insert Into dbo.Profile_Info(Profile_Id)values(@UserId)
if(@@Error>0)
begin

Rollback transaction t
end
else
begin
Commit transaction t
end
select * from Login_Table where EmailId=@EmailId
end
end
GO
/****** Object:  StoredProcedure [dbo].[spp_Save_AreaUnit_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_Save_AreaUnit_tbl]
(
@UnitId varchar(50),
@AreaUnitName nvarchar(50) = null,
@EqvUnitValueinSqrFt decimal = null,
@UnitOfLenth nvarchar(50) = null
)
as
begin
if Exists(select * from AreaUnit_tbl where [UnitId] = @UnitId)
begin
update AreaUnit_tbl set [UnitId]=@UnitId, [AreaUnitName]=@AreaUnitName, [EqvUnitValueinSqrFt]=@EqvUnitValueinSqrFt, [UnitOfLenth]=@UnitOfLenth
where [UnitId] = @UnitId
end
else
begin
insert into AreaUnit_tbl
([UnitId],[AreaUnitName],[EqvUnitValueinSqrFt],[UnitOfLenth])
values
(@UnitId,@AreaUnitName,@EqvUnitValueinSqrFt,@UnitOfLenth)
end
end
GO
/****** Object:  StoredProcedure [dbo].[spp_Save_FeatureCategory]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_Save_FeatureCategory]
(
@FeatureCatId varchar(50),
@FeatureCategory nvarchar(50),
@FeatureId varchar(50),
@FeatureName nvarchar(50),
@FeatureType nvarchar(50)
)
as
begin
begin transaction t

if not Exists(Select FeatureCatId from FeatureCategory where FeatureCategory=@FeatureCategory)
begin
insert into FeatureCategory
([FeatureCatId],[FeatureCategory],[EntryDate])
values
(@FeatureCatId,@FeatureCategory,GETDATE())
if not Exists(Select [FeatureName] from  [dbo].[FeatureMaster] where [FeatureName]=@FeatureName )
begin
insert into [dbo].[FeatureMaster](FeatureId, FeatureName, FeatureType, FeatureCatId)values(@FeatureId,@FeatureName,@FeatureType,@FeatureCatId)
end
end 

if(@@ERROR>0)
begin
Rollback transaction t
end
else
begin
commit transaction t

end

end



GO
/****** Object:  StoredProcedure [dbo].[spp_Save_Friends]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_Save_Friends]
(
@From varchar(50) = null,
@To varchar(50) = null,
@Status varchar(50) = null
)
as
begin

If Exists(Select * from Friends_tbl where [From]=@From and [To]=@To)
begin
Update Friends_tbl set [Status]=@Status where [From]=@From and [To]=@To and [Status]<>'accepted'
end
else
begin
insert into Friends_tbl
([From],[To],[Status],[EntryDate])
values
(@From,@To,@Status,GetDate())
end
end
GO
/****** Object:  StoredProcedure [dbo].[spp_SaveEvents]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_SaveEvents]
(

@EventId varchar(100),
@EventTitle nvarchar(100) = null,
@Description nvarchar(Max) = null,
@ShownType nvarchar(50) = null,
@ShowingDay int = null,
@Start_Date date = null,
@End_Date date = null,
@Start_Time time = null,
@End_Time time = null,
@CreatedBy varchar(100) = null,
@Event_Type varchar(50) = null,
@PropertyId	varchar(50)	=null
)
as
begin
if Exists(Select EventId from Events_Table where EventId=@EventId)
begin
update Events_Table set [EventId]=@EventId, [EventTitle]=@EventTitle, [Description]=@Description, [ShownType]=@ShownType, [ShowingDay]=@ShowingDay, [Start_Date]=@Start_Date, [End_Date]=@End_Date, [Start_Time]=@Start_Time, [End_Time]=@End_Time, [Event_Type]=@Event_Type,PropertyId=@PropertyId
where [EventId] = @EventId
end
else
begin
insert into Events_Table
([EventId],[EventTitle],[Description],[ShownType],[ShowingDay],[Start_Date],[End_Date],[Start_Time],[End_Time],[IsActive],[Entry_Date],[CreatedBy],[Event_Type],PropertyId)
values
(@EventId,@EventTitle,@Description,@ShownType,@ShowingDay,@Start_Date,@End_Date,@Start_Time,@End_Time,1,GetDate(),@CreatedBy,@Event_Type,@PropertyId)
end
end
GO
/****** Object:  StoredProcedure [dbo].[spp_SaveProfile_Info]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_SaveProfile_Info]
(
@Profile_Id nvarchar(50),
@FirstName nvarchar(100) = null,
@LastName nvarchar(100) = null,
@ContactNo varchar(13) = null,
@Address nvarchar(500) = null,
@City nvarchar(50) = null,
@State nvarchar(50) = null,
@Country nvarchar(50) = null,
@Zip nvarchar(10) = null,
@Photo nvarchar(500) = null,
@UserId nvarchar(200) = null,
@DOB date = null,
@Gender varchar(50) = null,
@Status bit = null,
@AboutMe nvarchar(MAX) = null,
@CCode varchar(5)=null,
@Latitude float=null,
@Longitude float=null,
@ScreenName nvarchar(50)=null
)
as
begin
if (Exists(Select Profile_Id from  Profile_Info where Profile_Id=@Profile_Id ))
begin
begin Transaction t
begin try 
update Profile_Info set   [ContactNo]=@ContactNo, [Address]=@Address, [City]=@City, [State]=@State, [Country]=@Country, [Zip]=@Zip, [Photo]=@Photo, [DOB]=@DOB, [Gender]=@Gender,AboutMe=@AboutMe,[Latitude]=@Latitude,[Longitude]=@Longitude,[Last_Modified_Date]=GETDATE()
,CCode=@CCode,[ScreenName]=@ScreenName where Profile_Id=@Profile_Id
Update Login_Table Set FirstName=@FirstName,LastName=@LastName where UserId=@Profile_Id
commit transaction t
end try
begin catch
Rollback transaction t
end catch
end
else
begin
insert into dbo.Profile_Info
(Profile_Id,[ContactNo],[Address],[City],[State],[Country],[Zip],[Photo],[DOB],[Gender],[Entry_Date],[Last_Modified_Date],AboutMe,CCode,[Latitude],[Longitude],[ScreenName])
values
(@Profile_Id,@ContactNo,@Address,@City,@State,@Country,@Zip,@Photo,@DOB,@Gender,GETDATE(),GETDATE(),@AboutMe,@CCode,@Latitude,@Longitude,@ScreenName)
end
end



GO
/****** Object:  StoredProcedure [dbo].[spp_SaveValuationRequest_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_SaveValuationRequest_tbl]
(
@Title nvarchar(10) = null,
@Name nvarchar(100) = null,
@PhoneNo varchar(12) = null,
@EmailId nvarchar(50) = null,
@Address nvarchar(500) = null,
@PostCode nvarchar(10) = null,
@Details nvarchar(500) = null,
@RequestFor varchar(20)=null
)
as
begin
insert into ValuationRequest_tbl
([Title],[Name],[PhoneNo],[EmailId],[Address],[PostCode],[Details],RequestFor)
values
(@Title,@Name,@PhoneNo,@EmailId,@Address,@PostCode,@Details,@RequestFor)
end
GO
/****** Object:  StoredProcedure [dbo].[spp_sendMessage]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_sendMessage]
(
@Msg_id varchar(200),
@Msg_From_User_Id varchar(100) = null,
@Msg_To_User_Id varchar(100) = null,
@Message nvarchar(max) = null,
@Msg_Status nvarchar(50) = null,
@Msg_Date datetime=null,
@Is_Read bit=0,
@IsPublic bit=0
)
as
begin
insert into [dbo].[Message]
(Msg_id,[Msg_From_User_Id],[Msg_To_User_Id],[Message],[Msg_Date],[Msg_Status],Deleted_By,[Is_Read],IsPublic)
values
(@Msg_id,@Msg_From_User_Id,@Msg_To_User_Id,@Message,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), getdate()),@Msg_Status,'NA','False',@IsPublic)
end
GO
/****** Object:  StoredProcedure [dbo].[Spp_SignUp]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Spp_SignUp]
(
@Uid	int	=null,
@UserId	nvarchar(200)=null,
@EmailId	nvarchar(500)	,
@FirstName	nvarchar(100)=null	,
@LastName	nvarchar(100)=null	,
@Password	nvarchar(500),
@CreatedBy nvarchar(50)=null
)
as
begin
declare @Status	bit	
if (exists (Select LoginId from Login_Table where UserId=@UserId)  )
begin
update Login_Table set  UserId=@UserId, EmailId=@EmailId, FirstName=@FirstName, LastName=@LastName, Password=@Password, Status=@Status where UserId=@UserId
end
else
begin
begin transaction t
begin
try
set @Status=1
if(Exists(select * from Login_Table where EmailId=@EmailId and isnull(googleid,'')<>''))
begin
update Login_Table set   FirstName=@FirstName, LastName=@LastName, Password=@Password,googleId='', Status=@Status where EmailId=@EmailId
end
else
begin
insert into Login_Table( Uid, UserId, EmailId, FirstName, LastName, Password, Status,[Email_verified])values(@Uid, @UserId, @EmailId, @FirstName, @LastName, @Password, @Status,0)
insert Into dbo.Profile_Info(Profile_Id,CreatedBy)values(@UserId,@CreatedBy)
end

Commit transaction t
end try
begin catch
Rollback transaction t
end catch
end

end



GO
/****** Object:  StoredProcedure [dbo].[spp_update_Agent_Picture]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_update_Agent_Picture]
(
@PhotoId varchar(50),
@Photo_Title nvarchar(200) = null,
@Photo nvarchar(50) = null
)
as
begin
update Agent_Picture set [Photo_Title]=@Photo_Title, [Photo]=@Photo
where [PhotoId] = @PhotoId
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_Area]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[spp_update_Area]
@AreaId int ,
@Area varchar(50)
as 
begin 
   update  Area_tbl  set Area=@Area where AreaId=@AreaId
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_Characteristic]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[spp_update_Characteristic]
@CharId bigint ,
@Characteristic nvarchar(50)
as 
begin 
   update  dbo.PropertyCharacteristics  set Characteristic=@Characteristic where CharId=@CharId
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_ClassifiedAds_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_update_ClassifiedAds_tbl]

(

@ClassifiedId varchar(50),

@Title nvarchar(100) = null,

@Pay_Type varchar(10) = null,

@Amount decimal = null,

@Image varchar(50)=null,

@Description nvarchar(max) = null,

@Contact_Name nvarchar(100) = null,

@Contact_Email nvarchar(100) = null,

@Contact_Phone varchar(20) = null,

@Contact_location nvarchar(100) = null,

@Catid varchar(50) = null,

@Latitude float = null,

@Longitude float = null

)

as

begin

update ClassifiedAds_tbl set  [Title]=@Title, [Pay_Type]=@Pay_Type, [Amount]=@Amount,[Image]= @Image,[Description]=@Description, [Contact_Name]=@Contact_Name, [Contact_Email]=@Contact_Email, [Contact_Phone]=@Contact_Phone, 

[Contact_location]=@Contact_location,Catid=@Catid,[Latitude]=@Latitude,[Longitude]=@Longitude

where [ClassifiedId] = @ClassifiedId

end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_ClassifiedFeature_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_update_ClassifiedFeature_tbl]
(
@CFeatureid varchar(50),
@Feature_Detail nvarchar(100) = null,
@Feature_Value nvarchar(100) = null
)
as
begin
update ClassifiedFeature_tbl set  [Feature_Detail]=@Feature_Detail, [Feature_Value]=@Feature_Value
where [CFeatureid] = @CFeatureid
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_ContactPage]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_update_ContactPage]
(
@Id bigint,
@Primary_Email nvarchar(100) = null,
@Secondary_Email nvarchar(100) = null,
@Primary_Contact varchar(50) = null,
@Secondary_Contact varchar(50) = null,
@Address nvarchar(100) = null,
@City nvarchar(50) = null,
@ZipCode nvarchar(20) = null
)
as
begin
update ContactPage set [Primary_Email]=@Primary_Email, [Secondary_Email]=@Secondary_Email, [Primary_Contact]=@Primary_Contact, [Secondary_Contact]=@Secondary_Contact, [Address]=@Address, [City]=@City, [ZipCode]=@ZipCode
where [Id] = @Id
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_Content_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_update_Content_tbl]
(
@Id int,
@Page_Name nvarchar(50) = null,
@Page_Title nvarchar(50) = null,
@Page_Heading nvarchar(MAX) = null,
@Section nvarchar(50) = null,
@Page_Content nvarchar(MAX) = null
)
as
begin
update Content_tbl set [Page_Name]=@Page_Name, [Page_Title]=@Page_Title, [Page_Heading]=@Page_Heading, [Section]=@Section, [Page_Content]=@Page_Content
where [Id] = @Id
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_Feature]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[spp_update_Feature]
@FeatureId varchar(50) ,
@FeatureName nvarchar(50),
@FeatureType nvarchar(50)
as 
begin 
   update  dbo.FeatureMaster  set FeatureName=@FeatureName,FeatureType=@FeatureType where FeatureId=@FeatureId
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_PriceHistory_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_update_PriceHistory_tbl]
(
@PriceId varchar(50),
@Date datetime = null,
@Event varchar(50) = null,
@Price decimal = null,
@Price_Sqft decimal = null,
@Source nvarchar(50) = null,
@PropertyId varchar(50) = null
)
as
begin
update PriceHistory_tbl set  [Date]=@Date, [Event]=@Event, [Price]=@Price, [Price_Sqft]=@Price_Sqft, [Source]=@Source
where [PriceId] = @PriceId and [PropertyId]=@PropertyId
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_Property_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_update_Property_tbl]
(
@PropertyId varchar(50),
@PropertyFor nvarchar(50) = null,
@PropertyTypeId varchar(50) = null,
@PropertyTitle nvarchar(200) = null,
@FrontImage varchar(200) = null,
@Price decimal = null,
@PriceUnit varchar(50) = null,
@Area decimal(18,2) = null,
@AreaUnit varchar(50) = null,
@PAgeId varchar(50) = null,
@Description nvarchar(MAX) = null,
@Address nvarchar(500) = null,
@City nvarchar(100) = null,
@State nvarchar(50) = null,
@PostCode nvarchar(50) = null,
@Latitude float = null,
@Longitude float = null,
@Video nvarchar(50) = null,
@Contact varchar(50) = null,
@FurnishedStatus nvarchar(50) = null,
@Features nvarchar(MAX)=null,
@PropertyImages varchar(MAx)=null,
@MLSNumber nvarchar(50)=null,
@LOTArea decimal(18,2)=null,
@LOTAreaUnit varchar(50)=null,
@YearBuilt int=null
)
as
begin
update Property_tbl set  [PropertyFor]=@PropertyFor, [PropertyTypeId]=@PropertyTypeId, [Property_Title]=@PropertyTitle,
 [FrontImage]=@FrontImage, [Price]=@Price, [PriceUnit]=@PriceUnit, [Area]=@Area, [AreaUnit]=@AreaUnit, [PAgeId]=@PAgeId, [Description]=@Description,
  [Address]=@Address, [City]=@City, [State]=@State, [PostCode]=@PostCode, [Latitude]=@Latitude, [Longitude]=@Longitude, [Video]=@Video, [Contact]=@Contact,
  FurnishedStatus=@FurnishedStatus,MLSNumber=@MLSNumber,LOTArea=@LOTArea,LOTAreaUnit=@LOTAreaUnit,YearBuilt=@YearBuilt
where [PropertyId] = @PropertyId

if(@Features<>'')
begin
Delete dbo.Property_Feature_Mapping where PropertyId=@PropertyId
Insert into dbo.Property_Feature_Mapping Select  Substring(Item, 1,Charindex('#', Item)-1) , @PropertyId,Substring(Item, Charindex('#', Item)+1, LEN(Item)) from dbo.Splitmaster(@Features,',') 
end
if(@PropertyImages<>'')
begin
--Delete [dbo].[Property_Images] where [PropertyId]=@PropertyId
insert into [dbo].[Property_Images](PropertyId, PrpertyImage)select @PropertyId,item from dbo.Splitmaster(@PropertyImages,',')
end

end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_Property_video]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_update_Property_video]
(
@VideoId varchar(50),
@PropertyId varchar(50) = null,
@Video_Title nvarchar(100) = null,
@File_Type nvarchar(20) = null,
@Video varchar(50) = null
)
as
begin
update Property_video set [VideoId]=@VideoId, [Video_Title]=@Video_Title, [File_Type]=@File_Type, [Video]=@Video
where [VideoId] = @VideoId and [PropertyId]=@PropertyId
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_PropertyAge]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[spp_update_PropertyAge]
@PAgeId bigint ,
@PropertyAge nvarchar(50)
as 
begin 
   update dbo.PropertyAgeMaster_tbl set PropertyAge=@PropertyAge where PAgeId=@PAgeId
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_PropertyType]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[spp_update_PropertyType] 
@PropertyTypeId varchar(50),
@PropertyType nvarchar(50)=null,
@PropertyTyp_Image varchar(50)=null,
@PropertyTypeCode nvarchar(50)=null
as 
begin 
   update  PropertyType_tbl  set PropertyType=@PropertyType,PropertyTypeCode=@PropertyTypeCode,
   PropertyTyp_Image=@PropertyTyp_Image where PropertyTypeId=@PropertyTypeId
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_SociallinkMapping_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_update_SociallinkMapping_tbl]
(
@SMID varchar(50),
@SocialId bigint = null,
@Social_link nvarchar(200) = null
)
as
begin
update SociallinkMapping_tbl set [SocialId]=@SocialId, [Social_link]=@Social_link
where [SMID]=@SMID
end
GO
/****** Object:  StoredProcedure [dbo].[spp_update_TaxHistory_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[spp_update_TaxHistory_tbl]
(
@TaxId varchar(50),
@Year bigint = null,
@PropertyTax decimal = null,
@PTax_Changes decimal = null,
@TaxAssessmnt decimal = null,
@TaxAssessmnt_Changes decimal = null,
@PropertyId varchar(50) = null
)
as
begin
update TaxHistory_tbl set  [Year]=@Year, [PropertyTax]=@PropertyTax, [PTax_Changes]=@PTax_Changes, [TaxAssessmnt]=@TaxAssessmnt, [TaxAssessmnt_Changes]=@TaxAssessmnt_Changes
where [TaxId] = @TaxId and [PropertyId]=@PropertyId
end



GO
/****** Object:  StoredProcedure [dbo].[spp_updatePage]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_updatePage]
(
 @id int,
 @Page_Name nvarchar(50),
 @Page_Title nvarchar(50),
 @Page_Heading ntext,
 @Page_Content ntext,
 @Page_Content2 ntext=null
) 
as
begin
 update dbo.Page set Page_Name=@Page_Name,Page_Title=@Page_Title,Page_Heading=@Page_Heading,Page_Content=@Page_Content,Page_Content2=@Page_Content2
 where id=@id
end
GO
/****** Object:  StoredProcedure [dbo].[spp_updateTestimonial]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_updateTestimonial]
(
@Tid varchar(50),
@Name nvarchar(100) = null,
@Designation nvarchar(50) = null,
@Comment nvarchar(200) = null,
@Photo varchar(50) = null
)
as
begin
update Testimonial set  [Name]=@Name, [Designation]=@Designation, [Comment]=@Comment, [Photo]=@Photo
where [Tid] = @Tid
end
GO
/****** Object:  StoredProcedure [dbo].[spp_User_ChangePassword]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spp_User_ChangePassword]
(
 @UserId varchar(100),
 @CurrPassword nvarchar(100)=null,
 @Password nvarchar(100)=null
)
as
begin
    declare @OldPass nvarchar(100)
    declare @Status nvarchar(100)
    select @OldPass=[Password]  from [dbo].[Login_Table] where UserId=@UserId
    
    set @Status='FAILED'
    if(@OldPass<>@CurrPassword)
    begin 
     set @Status='FAILED'
     select 'Current password is incorrect' as Msg,@Status  as [Status]
    end
    else
    begin
     update dbo.[Login_Table] set [Password]=@Password where UserId=@UserId
     set @Status='SUCCESS'
     select 'Password changed sucessfully' as Msg,@Status  as [Status]
    end
    
    
end
GO
/****** Object:  StoredProcedure [dbo].[TextSearch]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[TextSearch]
(    
@stringToFind nVARCHAR(100),
@schema sysname,
@table sysname,
@RColumnName varchar(50)
)
AS
BEGIN
Create table #temp(row int identity,keyword NVARCHAR(1000))
insert into #temp select item from[dbo].FullText_To_Table(@stringToFind)
DECLARE @sqlCommandfinal nvarchar(max)=''
declare @Output TABLE ( Item NVARCHAR(1000))
--declare @ParaDefination nvarchar(Max)
--set @ParaDefination='@Output TABLE (Item NVARCHAR(1000))'
declare @count int,@row bigint 
declare @string Nvarchar(1000)
select @count=count(row)from #temp
set @row=1
while (@row<=@count)
begin
set @string=''
Select @string=keyword from #temp where row=@row
if(@string<>'')
begin
set @string='%'+@string+'%'
 DECLARE @sqlCommand nvarchar(max) = 'SELECT ['+@RColumnName+'] FROM [' + @schema + '].[' + @table + '] WHERE ' 	   
   SELECT @sqlCommand = @sqlCommand + '[' + COLUMN_NAME + '] LIKE ''' + @string + ''' OR '
   FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE TABLE_SCHEMA = @schema
   AND TABLE_NAME = @table 
   AND DATA_TYPE IN ('char','nchar','ntext','nvarchar','text','varchar')   
   SET @sqlCommand = left(@sqlCommand,len(@sqlCommand)-3)
  set @sqlCommandfinal=@sqlCommandfinal+@sqlCommand
   if(@row<>@count)   
   SET @sqlCommandfinal=@sqlCommandfinal+' UNION '
   
     
end
   
   set @row=@row+1
end
   


Print @sqlCommandfinal

	insert into @Output(Item)  EXECUTE sp_executesql @sqlCommandfinal;
	Select * from @Output 
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateFeatureCategory]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UpdateFeatureCategory]
(
@FeatureCatId varchar(50),
@FeatureCategory nvarchar(50) = null
)
as
begin
if Exists(Select * from FeatureCategory where [FeatureCatId] = @FeatureCatId)
begin
update FeatureCategory set [FeatureCatId]=@FeatureCatId, [FeatureCategory]=@FeatureCategory
where [FeatureCatId] = @FeatureCatId
end
end
GO
/****** Object:  StoredProcedure [dbo].[updateSlide]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[updateSlide]
(
 @id int,
 @Slide_Name nvarchar(50),
 @Title nvarchar(250),
 @Image nvarchar(500)=null
)
as
begin
if(@Image is null)
begin
update Slide set Slide_Name=@Slide_Name,Title=@Title
 where id=@id
end
else
 begin
 update Slide set Slide_Name=@Slide_Name,Title=@Title,[Image]=@Image
 where id=@id
 end
end

GO
/****** Object:  UserDefinedFunction [dbo].[FullText_To_Table]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[FullText_To_Table]
(    
@stringToFind nvarchar(max)
)
RETURNS @Output TABLE ( Item NVARCHAR(1000))
as
begin

insert INTO @Output
Select * from
(
Select Item from dbo.Splitmaster(@stringToFind,' ')
Union
Select Item from dbo.Splitmaster(@stringToFind,',')
)A

Return
      
END


GO
/****** Object:  UserDefinedFunction [dbo].[FullTextSearchInquery]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create FUNCTION [dbo].[FullTextSearchInquery] 
(
@stringToFind VARCHAR(100),
@qry as varchar(MAX),
@RColumnName varchar(200),
@SearchOnColumns varchar(500)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

DECLARE @temp Table(row int identity,keyword NVARCHAR(1000))
insert into @temp select item from [dbo].FullText_To_Table(@stringToFind)
DECLARE @sqlCommandfinal nvarchar(max)=''
--declare @Output TABLE ( Item NVARCHAR(1000))


declare @count int,@row bigint 
declare @string Nvarchar(1000)
select @count=count(row)from @temp
set @row=1
while (@row<=@count)
begin
set @string=''
Select @string=keyword from @temp where row=@row
if(@string<>'')
begin
set @string='%'+@string+'%'
 DECLARE @sqlCommand nvarchar(max) = 'SELECT ['+@RColumnName+'] FROM ('+@qry+') A WHERE ' 	   
   SELECT @sqlCommand = @sqlCommand + '[' + COLUMN_NAME + '] LIKE ''' + @string + ''' OR '
   FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE 1=1
   --TABLE_SCHEMA = @schema
   --AND TABLE_NAME = @table 
   AND DATA_TYPE IN ('char','nchar','ntext','nvarchar','text','varchar')  
   AND COLUMN_NAME IN (Select Item as COLUMN_NAME from dbo.Splitmaster(@SearchOnColumns,','))
   SET @sqlCommand = left(@sqlCommand,len(@sqlCommand)-3)
  set @sqlCommandfinal=@sqlCommandfinal+@sqlCommand
   if(@row<>@count)   
   SET @sqlCommandfinal=@sqlCommandfinal+' UNION '
   
     
end
   
   set @row=@row+1
end
   
 
RETURN @sqlCommandfinal


END


GO
/****** Object:  UserDefinedFunction [dbo].[GetOpenHouseNewPropertyId]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetOpenHouseNewPropertyId]
(    
@CurDt datetime
)
RETURNS @Output TABLE (
PropertyId NVARCHAR(100),
[EventId] NVARCHAR(100),
[EventTitle] varchar(100),
[ShownType] varchar(50),
[ShowingDay] int,
[Start_Date] date,
[End_Date] date,
[Start_Time] time(7),
[End_Time] time(7),
[CreatedBy] varchar(100),
[Event_Type] varchar(50)
)
AS
BEGIN
	insert into @Output	Select PropertyId,[EventId],[EventTitle],[ShownType],[ShowingDay],[Start_Date],[End_Date],[Start_Time],[End_Time],[CreatedBy],[Event_Type] from [dbo].[View_Upcoming_Event] where 1=1 
	and IsActive=1 and Event_Type<>'REMINDER'
	and 
	(
	(((DATEPART(DW,@CurDt)-1)-ShowingDay)<=0 and ShownType='EVERY') or
	((convert(Date,@CurDt) between Cast([Start_Date] as Date) and Cast([End_Date] as Date)) and ShownType='BETWEEN') or
	((Convert(date,@CurDt)=(Cast([Start_Date] as Date))) and ShownType='DATE')
	)
	--declare @CurrentTime int
	--set @CurrentTime= (datepart(DW,@CurDt)-1)*10000+datepart(HH,@CurDt)*100+datepart(MI,@CurDt)

	--INSERT INTO @Output(PropertyId)
	--Select [PropertyId] from [dbo].[Events_Table] where
	--(
	--(datepart(DW,@CurDt)-1)=Isnull([ShowingDay],0) and
	--@CurrentTime between
	--((isnull([ShowingDay],0))*10000+datepart(HH,Cast(Start_Time as DateTime))*100+datepart(MI,cast(Start_Time as DateTime)))
	--and 
	--((Case when (datepart(HH,Cast(Start_Time as DateTime))*100+datepart(MI,cast(Start_Time as DateTime)))<(datepart(HH,Cast(End_Time as DateTime))*100+datepart(MI,cast(End_Time as DateTime))) then isnull([ShowingDay],0) else (isnull([ShowingDay],0)+1) end) *10000+datepart(HH,Cast(End_Time as DateTime))*100+datepart(MI,cast(End_Time as DateTime)))
	--)
	--or
	--(@CurDt between (Convert(Datetime,[Start_Date])+Cast([Start_Time] as  Datetime)) and ((Case when [Start_Time]>[End_Time] then DateAdd(DD,1,Convert(datetime,End_Date)) else Convert(datetime,End_Date) end)+Cast([End_Time] as Datetime)))
	--Or
	--(@CurDt between (Convert(Datetime,[Start_Date])+Cast([Start_Time] as  Datetime)) and ((Case when [Start_Time]>[End_Time] then DateAdd(DD,1,Convert(datetime,[Start_Date])) else Convert(datetime,[Start_Date]) end)+Cast([End_Time] as Datetime)))
    RETURN
END


GO
/****** Object:  UserDefinedFunction [dbo].[GetOpenHousePropertyId]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetOpenHousePropertyId]
(    
@CurDt datetime
)
RETURNS @Output TABLE (
PropertyId NVARCHAR(100)
)
AS
BEGIN	
	declare @CurrentTime int
	set @CurrentTime= (datepart(DW,@CurDt)-1)*10000+datepart(HH,@CurDt)*100+datepart(MI,@CurDt)

	INSERT INTO @Output(PropertyId)
	Select [PropertyId] from [dbo].[Events_Table] where
	(
	(datepart(DW,@CurDt)-1)=Isnull([ShowingDay],0) and
	@CurrentTime between
	((isnull([ShowingDay],0))*10000+datepart(HH,Cast(Start_Time as DateTime))*100+datepart(MI,cast(Start_Time as DateTime)))
	and 
	((Case when (datepart(HH,Cast(Start_Time as DateTime))*100+datepart(MI,cast(Start_Time as DateTime)))<(datepart(HH,Cast(End_Time as DateTime))*100+datepart(MI,cast(End_Time as DateTime))) then isnull([ShowingDay],0) else (isnull([ShowingDay],0)+1) end) *10000+datepart(HH,Cast(End_Time as DateTime))*100+datepart(MI,cast(End_Time as DateTime)))
	)
	or
	(@CurDt between (Convert(Datetime,[Start_Date])+Cast([Start_Time] as  Datetime)) and ((Case when [Start_Time]>[End_Time] then DateAdd(DD,1,Convert(datetime,End_Date)) else Convert(datetime,End_Date) end)+Cast([End_Time] as Datetime)))
	Or
	(@CurDt between (Convert(Datetime,[Start_Date])+Cast([Start_Time] as  Datetime)) and ((Case when [Start_Time]>[End_Time] then DateAdd(DD,1,Convert(datetime,[Start_Date])) else Convert(datetime,[Start_Date]) end)+Cast([End_Time] as Datetime)))
    RETURN
END


GO
/****** Object:  UserDefinedFunction [dbo].[GetUpcommingOpenHouse]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetUpcommingOpenHouse]
(    
@CurDt datetime,
@PropertyId varchar(50)
)
RETURNS @Output TABLE (
[EventId] NVARCHAR(100),
[EventTitle] varchar(100),
[ShownType] varchar(50),
[ShowingDay] int,
[Start_Date] date,
[End_Date] date,
[Start_Time] time(7),
[End_Time] time(7),
[CreatedBy] varchar(100),
[Event_Type] varchar(50)
)
AS
BEGIN	
insert into @Output	Select [EventId],[EventTitle],[ShownType],[ShowingDay],[Start_Date],[End_Date],[Start_Time],[End_Time],[CreatedBy],[Event_Type] from [dbo].[View_Upcoming_Event] where 1=1 
	and PropertyId=@PropertyId and IsActive=1 and Event_Type<>'REMINDER'
	and 
    (
    ((((DATEPART(DW,@CurDt)-1)-ShowingDay)<=0 and ShownType='EVERY') Or (ShowingDay=0 and ShownType='EVERY')) 
	or (((End_Time is not null and Start_Time is not null) and @CurDt<=(Cast([End_Date] as DateTime)+Cast(End_Time as DateTime)))    
	Or (convert(Date,@CurDt)<=Cast([End_Date] as DateTime)  and  (End_Time is null or Start_Time is null)) and ShownType='BETWEEN')
    or (((End_Time is not null and Start_Time is not null) and @CurDt<=(Cast([Start_Date] as Datetime)+Cast(End_Time as DateTime))) Or (Convert(date,@CurDt)<=(Cast([Start_Date] as Date)) and (End_Time is null or Start_Time is null)) and ShownType='DATE')
    )
	return 
END
GO
/****** Object:  UserDefinedFunction [dbo].[MyFullTextSearch]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[MyFullTextSearch] 
(
@stringToFind VARCHAR(100),
@schema sysname,
@table sysname,
@RColumnName varchar(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

DECLARE @temp Table(row int identity,keyword NVARCHAR(1000))
--insert into @temp select item from[dbo].FullText_To_Table(@stringToFind)
---------------Split String By Space and Comma
insert INTO @temp
Select * from
(
Select Item from dbo.Splitmaster(@stringToFind,' ')
Union
Select Item from dbo.Splitmaster(@stringToFind,',')
)A



DECLARE @sqlCommandfinal nvarchar(max)=''
--declare @Output TABLE ( Item NVARCHAR(1000))


declare @count int,@row bigint 
declare @string Nvarchar(1000)
select @count=count(row)from @temp
set @row=1
while (@row<=@count)
begin
set @string=''
Select @string=keyword from @temp where row=@row
if(@string<>'')
begin
set @string='%'+@string+'%'
 DECLARE @sqlCommand nvarchar(max) = 'SELECT ['+@RColumnName+'] FROM [' + @schema + '].[' + @table + '] WHERE ' 	   
   SELECT @sqlCommand = @sqlCommand + '[' + COLUMN_NAME + '] LIKE ''' + @string + ''' OR '
   FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE TABLE_SCHEMA = @schema
   AND TABLE_NAME = @table 
   AND DATA_TYPE IN ('char','nchar','ntext','nvarchar','text','varchar')   
   SET @sqlCommand = left(@sqlCommand,len(@sqlCommand)-3)
  set @sqlCommandfinal=@sqlCommandfinal+@sqlCommand
   if(@row<>@count)   
   SET @sqlCommandfinal=@sqlCommandfinal+' UNION '
   
     
end
   
   set @row=@row+1
end
   
 
RETURN @sqlCommandfinal


END


GO
/****** Object:  UserDefinedFunction [dbo].[MyFullTextSearchNew]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create FUNCTION [dbo].[MyFullTextSearchNew] 
(
@stringToFind VARCHAR(100),
@schema sysname,
@table sysname,
@RColumnName varchar(200),
@SearchOnColumns varchar(500)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

DECLARE @temp Table(row int identity,keyword NVARCHAR(1000))
insert into @temp select item from[dbo].FullText_To_Table(@stringToFind)
DECLARE @sqlCommandfinal nvarchar(max)=''
--declare @Output TABLE ( Item NVARCHAR(1000))


declare @count int,@row bigint 
declare @string Nvarchar(1000)
select @count=count(row)from @temp
set @row=1
while (@row<=@count)
begin
set @string=''
Select @string=keyword from @temp where row=@row
if(@string<>'')
begin
set @string='%'+@string+'%'
 DECLARE @sqlCommand nvarchar(max) = 'SELECT ['+@RColumnName+'] FROM [' + @schema + '].[' + @table + '] WHERE ' 	   
   SELECT @sqlCommand = @sqlCommand + '[' + COLUMN_NAME + '] LIKE ''' + @string + ''' OR '
   FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE TABLE_SCHEMA = @schema
   AND TABLE_NAME = @table 
   AND DATA_TYPE IN ('char','nchar','ntext','nvarchar','text','varchar')  
   AND COLUMN_NAME IN (Select Item as COLUMN_NAME from dbo.Splitmaster(@SearchOnColumns,','))
   SET @sqlCommand = left(@sqlCommand,len(@sqlCommand)-3)
  set @sqlCommandfinal=@sqlCommandfinal+@sqlCommand
   if(@row<>@count)   
   SET @sqlCommandfinal=@sqlCommandfinal+' UNION '
   
     
end
   
   set @row=@row+1
end
   
 
RETURN @sqlCommandfinal


END


GO
/****** Object:  UserDefinedFunction [dbo].[Splitmaster]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[Splitmaster]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS @Output TABLE (
      Item NVARCHAR(1000)
)
AS
BEGIN
     
									DECLARE @S varchar(max),
										@Split char(1),
										@X xml

										SELECT @S =@Input,
										@Split = @Character

										SELECT @X = CONVERT(xml,'<root><s>' + REPLACE(@S,@Split,'</s><s>') + '</s></root>')

										INSERT INTO @Output(Item)
										SELECT  T.c.value('.','varchar(50)')
										FROM @X.nodes('/root/s') T(c)

 
      RETURN
END




--select item from [dbo].[Splitmaster]('1,2,3,2',',')



GO
/****** Object:  UserDefinedFunction [dbo].[SplitString]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[SplitString]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS @Output TABLE (
      Item NVARCHAR(1000)
)
AS
BEGIN
      DECLARE @StartIndex INT, @EndIndex INT
 
      SET @StartIndex = 1
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
      BEGIN
            SET @Input = @Input + @Character
      END
 
      WHILE CHARINDEX(@Character, @Input) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Input)
           
            INSERT INTO @Output(Item)
            SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)
           
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
      END
 
      RETURN
END



GO
/****** Object:  Table [dbo].[Admin]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Admin](
	[Id] [int] NOT NULL,
	[username] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](50) NULL,
 CONSTRAINT [PK_Admin] PRIMARY KEY CLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Ads_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ads_tbl](
	[AdId] [varchar](50) NOT NULL,
	[Ad_Image] [varchar](50) NULL,
	[Ad_Description] [nvarchar](max) NULL,
	[City] [nvarchar](50) NULL,
	[ZipCode] [nvarchar](50) NULL,
	[Link] [nvarchar](500) NULL,
	[EntryDate] [varchar](50) NULL,
	[Status] [bit] NULL,
 CONSTRAINT [PK_Ads_tbl] PRIMARY KEY CLUSTERED 
(
	[AdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Agent_Picture]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Agent_Picture](
	[PhotoId] [varchar](50) NOT NULL,
	[Photo_Title] [nvarchar](200) NULL,
	[Photo] [varchar](50) NULL,
	[Photo_Entrydate] [datetime] NULL,
	[Profile_Id] [varchar](50) NULL,
 CONSTRAINT [PK_Agent_Picture] PRIMARY KEY CLUSTERED 
(
	[PhotoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Agent_Review_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Agent_Review_tbl](
	[ReviewId] [bigint] IDENTITY(1,1) NOT NULL,
	[Rating] [int] NULL,
	[ReviewText] [nvarchar](max) NULL,
	[AgentId] [varchar](50) NULL,
	[UserId] [varchar](50) NULL,
	[ReviewDate] [datetime] NULL,
 CONSTRAINT [PK_Agent_Review_tbl] PRIMARY KEY CLUSTERED 
(
	[ReviewId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Agent_Video]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Agent_Video](
	[VideoId] [varchar](50) NOT NULL,
	[Video_Title] [nvarchar](50) NULL,
	[File_Type] [nvarchar](20) NULL,
	[Video] [varchar](50) NULL,
	[Video_Entrydate] [datetime] NULL,
	[Profile_Id] [varchar](50) NULL,
 CONSTRAINT [PK_Agent_Video] PRIMARY KEY CLUSTERED 
(
	[VideoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AgentContact_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AgentContact_tbl](
	[AgentContact_Id] [varchar](50) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Phone] [varchar](20) NULL,
	[Email] [nvarchar](100) NULL,
	[Message] [nvarchar](500) NULL,
	[PropertyId] [varchar](50) NULL,
	[Profile_Id] [varchar](50) NULL,
	[Entry_Date] [datetime] NULL,
	[Status] [varchar](10) NULL,
	[AgentId] [varchar](50) NULL,
 CONSTRAINT [PK_AgentContact_tbl] PRIMARY KEY CLUSTERED 
(
	[AgentContact_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Area_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Area_tbl](
	[AreaId] [bigint] IDENTITY(1,1) NOT NULL,
	[Area] [nvarchar](50) NULL,
 CONSTRAINT [PK_Area_tbl] PRIMARY KEY CLUSTERED 
(
	[AreaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AreaUnit_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AreaUnit_tbl](
	[UnitId] [varchar](50) NOT NULL,
	[AreaUnitName] [varchar](50) NULL,
	[EqvUnitValueinSqrFt] [decimal](18, 2) NULL,
	[UnitOfLenth] [varchar](50) NULL,
 CONSTRAINT [PK_AreaUnit_tbl] PRIMARY KEY CLUSTERED 
(
	[UnitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Arrange_Viewing]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Arrange_Viewing](
	[Viewing_Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[EmailId] [nvarchar](50) NULL,
	[Primary_Telephone] [nvarchar](50) NULL,
	[Work_Telephone] [nvarchar](50) NULL,
	[MobileNo] [nvarchar](50) NULL,
	[Viewing_Date] [date] NULL,
	[Time_of_Day] [nvarchar](50) NULL,
	[Other_Requirement] [nvarchar](500) NULL,
	[UserId] [nvarchar](200) NULL,
	[PropertyId] [varchar](50) NULL,
 CONSTRAINT [PK_Arrange_Viewing] PRIMARY KEY CLUSTERED 
(
	[Viewing_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClassifiedAds_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClassifiedAds_tbl](
	[ClassifiedId] [varchar](50) NOT NULL,
	[Title] [nvarchar](100) NULL,
	[Pay_Type] [varchar](10) NULL,
	[Amount] [decimal](18, 2) NULL,
	[Image] [varchar](50) NULL,
	[Description] [nvarchar](max) NULL,
	[Contact_Name] [nvarchar](100) NULL,
	[Contact_Email] [nvarchar](100) NULL,
	[Contact_Phone] [varchar](20) NULL,
	[Contact_location] [nvarchar](100) NULL,
	[ClassifiedEntry_Date] [datetime] NULL,
	[ClassifiedStatus] [bit] NULL,
	[Catid] [varchar](50) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
 CONSTRAINT [PK_ClassifiedAds_tbl] PRIMARY KEY CLUSTERED 
(
	[ClassifiedId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClassifiedCategory]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClassifiedCategory](
	[Catid] [varchar](50) NOT NULL,
	[CategoryName] [nvarchar](100) NULL,
	[Image] [varchar](100) NULL,
	[IsActive] [bit] NULL,
	[EntryDate] [datetime] NULL,
 CONSTRAINT [PK_ClassifiedCategory] PRIMARY KEY CLUSTERED 
(
	[Catid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClassifiedFeature_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClassifiedFeature_tbl](
	[CFeatureid] [varchar](50) NOT NULL,
	[ClassifiedId] [varchar](50) NULL,
	[Feature_Detail] [nvarchar](100) NULL,
	[Feature_Value] [nvarchar](100) NULL,
	[FeatureEntry_Date] [datetime] NULL,
	[Feature_Status] [bit] NULL,
 CONSTRAINT [PK_ClassifiedFeature_tbl] PRIMARY KEY CLUSTERED 
(
	[CFeatureid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClassifiedPostImg_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClassifiedPostImg_tbl](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ClassifiedId] [varchar](50) NULL,
	[Post_Images] [varchar](50) NULL,
 CONSTRAINT [PK_ClassifiedPostImg_tbl] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CMS_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CMS_tbl](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Imagefor] [nvarchar](50) NULL,
	[Image] [varchar](50) NULL,
	[Title] [nvarchar](100) NULL,
	[Sub_Title] [nvarchar](100) NULL,
 CONSTRAINT [PK_CMS_tbl] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Contact_Tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Contact_Tbl](
	[CId] [bigint] IDENTITY(1,1) NOT NULL,
	[ContactId] [varchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Email] [nvarchar](100) NULL,
	[Contact] [nvarchar](20) NULL,
	[Subject] [nvarchar](100) NULL,
	[Message] [nvarchar](500) NULL,
	[Entrydate] [datetime] NULL,
	[Status] [bit] NULL,
 CONSTRAINT [PK_Contact_Tbl] PRIMARY KEY CLUSTERED 
(
	[CId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ContactPage]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ContactPage](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Primary_Email] [nvarchar](100) NULL,
	[Secondary_Email] [nvarchar](100) NULL,
	[Primary_Contact] [varchar](50) NULL,
	[Secondary_Contact] [varchar](50) NULL,
	[Address] [nvarchar](100) NULL,
	[City] [nvarchar](50) NULL,
	[ZipCode] [nvarchar](50) NULL,
	[Status] [bit] NULL,
 CONSTRAINT [PK_ContactPage_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Content_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Content_tbl](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Page_Name] [nvarchar](50) NULL,
	[Page_Title] [nvarchar](50) NULL,
	[Page_Heading] [nvarchar](max) NULL,
	[Section] [nvarchar](50) NULL,
	[Page_Content] [nvarchar](max) NULL,
 CONSTRAINT [PK_Content_tbl] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Events_Table]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Events_Table](
	[EventId] [varchar](100) NOT NULL,
	[EventTitle] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[ShownType] [nvarchar](50) NULL,
	[ShowingDay] [int] NULL,
	[Start_Date] [date] NULL,
	[End_Date] [date] NULL,
	[Start_Time] [time](7) NULL,
	[End_Time] [time](7) NULL,
	[IsActive] [bit] NULL,
	[Entry_Date] [datetime] NULL,
	[CreatedBy] [varchar](100) NULL,
	[Event_Type] [varchar](50) NULL,
	[PropertyId] [varchar](50) NULL,
	[DisplayStatus] [varchar](10) NULL,
 CONSTRAINT [PK_Events_Table] PRIMARY KEY CLUSTERED 
(
	[EventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Favourite_Property]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Favourite_Property](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Profile_Id] [varchar](50) NULL,
	[PropertyId] [varchar](50) NULL,
	[Entrydate] [datetime] NULL,
 CONSTRAINT [PK_Favourite_Property] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FeatureCategory]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FeatureCategory](
	[FeatureCatId] [varchar](50) NOT NULL,
	[FeatureCategory] [nvarchar](50) NULL,
	[EntryDate] [datetime] NULL,
 CONSTRAINT [PK_FeatureCategory] PRIMARY KEY CLUSTERED 
(
	[FeatureCatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FeatureMaster]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FeatureMaster](
	[FeatureId] [varchar](50) NOT NULL,
	[FeatureName] [nvarchar](50) NULL,
	[FeatureType] [nvarchar](50) NULL,
	[FeatureCatId] [varchar](50) NULL,
	[IsDefault] [bit] NULL,
 CONSTRAINT [PK_FeatureMaster] PRIMARY KEY CLUSTERED 
(
	[FeatureId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Friends_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Friends_tbl](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[From] [varchar](50) NULL,
	[To] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[EntryDate] [datetime] NULL,
 CONSTRAINT [PK_Friends_tbl] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Gallery]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Gallery](
	[id] [nvarchar](50) NOT NULL,
	[Title] [varchar](50) NOT NULL,
	[Image] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Gallery] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Holiday_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Holiday_tbl](
	[HolidayId] [varchar](50) NOT NULL,
	[Holiday_Name] [varchar](100) NULL,
	[Holiday_On] [varchar](20) NULL,
	[Holiday_Date] [date] NULL,
	[Start_Date] [date] NULL,
	[End_Date] [date] NULL,
	[About_Holiday] [varchar](200) NULL,
	[Entry_Date] [datetime] NULL,
 CONSTRAINT [PK_Holiday_tbl] PRIMARY KEY CLUSTERED 
(
	[HolidayId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Login_Table]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Login_Table](
	[LoginId] [bigint] IDENTITY(1,1) NOT NULL,
	[Uid] [int] NULL,
	[UserId] [nvarchar](200) NULL,
	[EmailId] [nvarchar](500) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[Password] [nvarchar](500) NULL,
	[Status] [bit] NULL,
	[Email_verified] [bit] NULL,
	[Last_visited] [datetime] NULL,
	[googleId] [varchar](50) NULL,
 CONSTRAINT [PK__Login_Ta__4DDA281815705F24] PRIMARY KEY CLUSTERED 
(
	[LoginId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Message]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Message](
	[Msg_id] [varchar](200) NOT NULL,
	[msg_from_user_id] [varchar](100) NULL,
	[Msg_To_User_Id] [varchar](100) NULL,
	[Message] [nvarchar](max) NULL,
	[Is_Read] [bit] NULL,
	[Msg_Date] [datetime] NULL,
	[Msg_Status] [varchar](50) NULL,
	[Deleted_By] [varchar](100) NULL,
	[IsPublic] [bit] NULL,
 CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED 
(
	[Msg_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Notes_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Notes_tbl](
	[Id] [varchar](50) NOT NULL,
	[NoteText] [nvarchar](max) NULL,
	[IsPublic] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[PropertyId] [varchar](50) NULL,
	[Position] [varchar](50) NULL,
	[posX] [varchar](50) NULL,
	[PosY] [varchar](50) NULL,
 CONSTRAINT [PK_Notes_tbl] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Page]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Page](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Page_Name] [nvarchar](50) NULL,
	[Page_Title] [nvarchar](50) NULL,
	[Page_Heading] [text] NULL,
	[Page_Content] [text] NULL,
	[Page_Content2] [text] NULL,
 CONSTRAINT [PK_Page] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PriceHistory_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceHistory_tbl](
	[PriceId] [varchar](50) NOT NULL,
	[Date] [datetime] NULL,
	[Event] [varchar](50) NULL,
	[Price] [decimal](18, 3) NULL,
	[Price_Sqft] [decimal](18, 3) NULL,
	[Source] [varchar](50) NULL,
	[PropertyId] [varchar](50) NULL,
	[Entry_Date] [datetime] NULL,
 CONSTRAINT [PK_PriceHistory_tbl] PRIMARY KEY CLUSTERED 
(
	[PriceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Profile_Info]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Profile_Info](
	[ProfileSrl] [bigint] IDENTITY(1,1) NOT NULL,
	[Profile_Id] [nvarchar](50) NULL,
	[LoginId] [bigint] NULL,
	[ContactNo] [varchar](12) NULL,
	[Address] [nvarchar](500) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Zip] [varchar](10) NULL,
	[Photo] [nvarchar](500) NULL,
	[Gender] [varchar](50) NULL,
	[Entry_Date] [date] NULL,
	[Last_Modified_Date] [date] NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[DOB] [date] NULL,
	[AboutMe] [nvarchar](max) NULL,
	[CCode] [varchar](5) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[ScreenName] [varchar](50) NULL,
 CONSTRAINT [PK_Patient_Info_1] PRIMARY KEY CLUSTERED 
(
	[ProfileSrl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Propert_Age_Mapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Propert_Age_Mapping](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[PAgeId] [bigint] NULL,
	[PropertyId] [varchar](50) NULL,
 CONSTRAINT [PK_Propert_Age_Mapping] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Property_Characteristic_Mapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Property_Characteristic_Mapping](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CharId] [bigint] NULL,
	[PropertyId] [varchar](50) NULL,
 CONSTRAINT [PK_Property_Characteristic_Mapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Property_Feature_Mapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Property_Feature_Mapping](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[FeatureId] [varchar](50) NULL,
	[PropertyId] [varchar](50) NULL,
	[FeatureValue] [varchar](50) NULL,
 CONSTRAINT [PK_Property_Feature_Mapping] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Property_Images]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Property_Images](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[PropertyId] [varchar](50) NULL,
	[PrpertyImage] [nvarchar](max) NULL,
	[ImageFor] [varchar](50) NULL,
 CONSTRAINT [PK_Property_Images] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Property_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Property_tbl](
	[PropertyId] [varchar](50) NOT NULL,
	[PropertyFor] [varchar](50) NULL,
	[PropertyTypeId] [varchar](50) NULL,
	[FrontImage] [varchar](200) NULL,
	[Price] [decimal](18, 2) NULL,
	[PriceUnit] [varchar](50) NULL,
	[Area] [decimal](18, 2) NULL,
	[AreaUnit] [varchar](50) NULL,
	[PAgeId] [varchar](50) NULL,
	[Description] [nvarchar](max) NULL,
	[Address] [varchar](500) NULL,
	[City] [varchar](100) NULL,
	[State] [varchar](50) NULL,
	[PostCode] [varchar](50) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[Video] [varchar](50) NULL,
	[Contact] [varchar](50) NULL,
	[CreatedBy] [varchar](50) NULL,
	[CreatedOn] [datetime] NULL,
	[FurnishedStatus] [varchar](50) NULL,
	[Property_Status] [bit] NULL,
	[Property_Title] [nvarchar](200) NULL,
	[Featured] [varchar](20) NULL,
	[IsSold] [varchar](10) NULL,
	[MLSNumber] [varchar](50) NULL,
	[LOTArea] [decimal](18, 2) NULL,
	[LOTAreaUnit] [varchar](50) NULL,
	[YearBuilt] [int] NULL,
	[DateOnMarker] [datetime] NULL,
	[PerAreaPrice] [decimal](18, 2) NULL,
	[PerAreaUnit] [varchar](50) NULL,
 CONSTRAINT [PK_Property_tbl_1] PRIMARY KEY CLUSTERED 
(
	[PropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Property_video]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Property_video](
	[VideoId] [varchar](50) NOT NULL,
	[PropertyId] [varchar](50) NULL,
	[Video_Title] [varchar](100) NULL,
	[File_Type] [varchar](20) NULL,
	[Video] [varchar](50) NULL,
	[Video_Entrydate] [datetime] NULL,
 CONSTRAINT [PK_Property_video] PRIMARY KEY CLUSTERED 
(
	[VideoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PropertyAgeMaster_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PropertyAgeMaster_tbl](
	[PAgeId] [bigint] IDENTITY(1,1) NOT NULL,
	[PropertyAge] [varchar](50) NULL,
 CONSTRAINT [PK_PropertyAge_tbl] PRIMARY KEY CLUSTERED 
(
	[PAgeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PropertyCharacteristics]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PropertyCharacteristics](
	[CharId] [bigint] IDENTITY(1,1) NOT NULL,
	[Characteristic] [varchar](50) NULL,
 CONSTRAINT [PK_PropertyCharacteristics] PRIMARY KEY CLUSTERED 
(
	[CharId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PropertyType_Pfor_mapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PropertyType_Pfor_mapping](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[PropertyTypeId] [varchar](50) NULL,
	[PropertyFor] [varchar](50) NULL,
 CONSTRAINT [PK_PropertyType_Pfor_mapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PropertyType_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PropertyType_tbl](
	[PropertyTypeId] [varchar](50) NOT NULL,
	[PropertyType] [varchar](50) NULL,
	[PropertyTyp_Image] [varchar](50) NULL,
	[RentPossible] [bit] NULL,
	[IsActive] [bit] NULL,
	[PropertyTypeCode] [varchar](50) NULL,
 CONSTRAINT [PK_PropertyType_tbl] PRIMARY KEY CLUSTERED 
(
	[PropertyTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProprtyType_Feature_Mapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProprtyType_Feature_Mapping](
	[Feature_Ptype_Mapping_Id] [bigint] IDENTITY(1,1) NOT NULL,
	[FeatureId] [varchar](50) NULL,
	[PropertyTypeId] [varchar](50) NULL,
 CONSTRAINT [PK_ProprtyType_Feature_Mapping] PRIMARY KEY CLUSTERED 
(
	[Feature_Ptype_Mapping_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RecentSearchTbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RecentSearchTbl](
	[SrlNo] [bigint] IDENTITY(1,1) NOT NULL,
	[UniqueId] [nvarchar](500) NULL,
	[SearchId] [varchar](50) NULL,
	[SearchType] [varchar](50) NULL,
	[SearchName] [varchar](500) NULL,
 CONSTRAINT [PK_RecentSearchTbl] PRIMARY KEY CLUSTERED 
(
	[SrlNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SavedProperty_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SavedProperty_tbl](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[LoginId] [varchar](50) NULL,
	[PropertyId] [varchar](50) NULL,
 CONSTRAINT [PK_SavedProperty_tbl] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Search_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Search_tbl](
	[SrlNo] [bigint] IDENTITY(1,1) NOT NULL,
	[uniqueId] [nvarchar](500) NULL,
	[Location] [varchar](500) NULL,
	[MinPrice] [bigint] NULL,
	[MaxPrice] [bigint] NULL,
	[MinBed] [int] NULL,
 CONSTRAINT [PK_Search_tbl] PRIMARY KEY CLUSTERED 
(
	[SrlNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Slide]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Slide](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Slide_Name] [varchar](50) NULL,
	[Title] [nvarchar](250) NULL,
	[Image] [nvarchar](500) NULL,
 CONSTRAINT [PK_Slide] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Social]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Social](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Facebook] [nvarchar](100) NULL,
	[Twitter] [nvarchar](100) NULL,
	[Instagram] [nvarchar](100) NULL,
	[Googleplus] [nvarchar](100) NULL,
	[Youtube] [nvarchar](100) NULL,
	[Linkedin] [nvarchar](100) NULL,
 CONSTRAINT [PK_Social] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SociallinkMapping_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SociallinkMapping_tbl](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[SMID] [varchar](50) NOT NULL,
	[SocialId] [bigint] NULL,
	[UserId] [nvarchar](200) NULL,
	[Social_link] [varchar](200) NULL,
	[Entrydate] [datetime] NULL,
 CONSTRAINT [PK_SociallinkMapping_tbl] PRIMARY KEY CLUSTERED 
(
	[SMID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SociallinkMaster_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SociallinkMaster_tbl](
	[SocialId] [bigint] IDENTITY(1,1) NOT NULL,
	[Social_Site] [varchar](100) NULL,
	[Social_Icon] [varchar](50) NULL,
 CONSTRAINT [PK_SociallinkMaster_tbl] PRIMARY KEY CLUSTERED 
(
	[SocialId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StampDuty_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StampDuty_tbl](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[AFrom] [decimal](18, 2) NULL,
	[ATo] [decimal](18, 2) NULL,
	[SRate] [decimal](18, 2) NULL,
	[SecondHrate] [decimal](18, 2) NULL,
 CONSTRAINT [PK_StampDuty_tbl] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Subscription_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Subscription_tbl](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SubscripId] [varchar](50) NULL,
	[Email] [varchar](100) NULL,
	[IsSuscribed] [bit] NULL,
	[Entrydate] [datetime] NULL,
 CONSTRAINT [PK_Subscription_tbl] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TaxHistory_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TaxHistory_tbl](
	[TaxId] [varchar](50) NOT NULL,
	[Year] [bigint] NULL,
	[PropertyTax] [decimal](18, 3) NULL,
	[PTax_Changes] [decimal](18, 0) NULL,
	[TaxAssessmnt] [decimal](18, 3) NULL,
	[TaxAssessmnt_Changes] [decimal](18, 0) NULL,
	[PropertyId] [varchar](50) NULL,
	[Entry_Date] [datetime] NULL,
 CONSTRAINT [PK_TaxHistory_tbl] PRIMARY KEY CLUSTERED 
(
	[TaxId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblCMS]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblCMS](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Meta_Tag] [nvarchar](50) NULL,
	[Meta_Description] [varchar](max) NULL,
	[Page_Name] [nvarchar](50) NULL,
	[Page_Title] [nvarchar](50) NULL,
	[Page_Heading] [nvarchar](max) NULL,
	[Section] [nvarchar](50) NULL,
	[Page_Content] [nvarchar](max) NULL,
 CONSTRAINT [PK_tblCMS] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Testimonial]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Testimonial](
	[Tid] [varchar](50) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Designation] [nvarchar](50) NULL,
	[Comment] [nvarchar](200) NULL,
	[Photo] [varchar](50) NULL,
	[Status] [varchar](10) NULL,
	[Entry_Date] [datetime] NULL,
 CONSTRAINT [PK_Testimonial] PRIMARY KEY CLUSTERED 
(
	[Tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User_Type]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User_Type](
	[Uid] [int] NOT NULL,
	[UserTypeName] [varchar](50) NULL,
	[DisplayName] [varchar](50) NULL,
 CONSTRAINT [PK_User_Type] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ValuationRequest_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ValuationRequest_tbl](
	[SrlNo] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](10) NULL,
	[Name] [varchar](100) NULL,
	[PhoneNo] [varchar](12) NULL,
	[EmailId] [varchar](50) NULL,
	[Address] [varchar](500) NULL,
	[PostCode] [varchar](10) NULL,
	[Details] [varchar](500) NULL,
	[RequestFor] [varchar](20) NULL,
 CONSTRAINT [PK_ValuationRequest_tbl] PRIMARY KEY CLUSTERED 
(
	[SrlNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WeekDay_tbl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WeekDay_tbl](
	[WeekDayName] [varchar](50) NULL,
	[Week_Day] [tinyint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[View_Login_Profile]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Login_Profile]
AS
SELECT        dbo.Login_Table.LoginId, dbo.Login_Table.Uid, dbo.Login_Table.UserId, dbo.Login_Table.EmailId, dbo.Login_Table.FirstName, dbo.Login_Table.LastName, 
                         dbo.Login_Table.Password, dbo.Login_Table.Status, dbo.User_Type.UserTypeName, dbo.Profile_Info.ProfileSrl, dbo.Profile_Info.Profile_Id, 
                         dbo.Profile_Info.ContactNo, dbo.Profile_Info.Address, dbo.Profile_Info.City, dbo.Profile_Info.State, dbo.Profile_Info.Country, dbo.Profile_Info.Zip, 
                         dbo.Profile_Info.Photo, dbo.Profile_Info.DOB, dbo.Profile_Info.Gender, dbo.Profile_Info.Entry_Date, dbo.Profile_Info.Last_Modified_Date, dbo.Profile_Info.CreatedBy, 
                         dbo.User_Type.DisplayName, dbo.Profile_Info.AboutMe, dbo.Profile_Info.CCode,
                             (SELECT        ISNULL(AVG(Rating), 0) AS Expr1
                               FROM            dbo.Agent_Review_tbl
                               WHERE        (UserId = dbo.Login_Table.UserId)) AS Rating, dbo.Profile_Info.ScreenName, dbo.Profile_Info.Longitude, dbo.Profile_Info.Latitude, 
                         dbo.Login_Table.Last_visited
FROM            dbo.User_Type INNER JOIN
                         dbo.Login_Table ON dbo.User_Type.Uid = dbo.Login_Table.Uid LEFT OUTER JOIN
                         dbo.Profile_Info ON dbo.Login_Table.UserId = dbo.Profile_Info.Profile_Id

GO
/****** Object:  View [dbo].[View_SearchProperty]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_SearchProperty]
AS
SELECT        dbo.Property_tbl.PropertyId, dbo.Property_tbl.Address, dbo.Property_tbl.City, dbo.Property_tbl.State, dbo.Property_tbl.PostCode, dbo.Property_tbl.Video, 
                         dbo.Property_tbl.Contact, dbo.Property_tbl.PropertyTypeId, dbo.Property_tbl.FrontImage, dbo.PropertyType_tbl.PropertyType, dbo.Property_tbl.CreatedBy, 
                         dbo.PropertyAgeMaster_tbl.PropertyAge, dbo.Property_tbl.Latitude, dbo.Property_tbl.Longitude, dbo.Property_tbl.FurnishedStatus, dbo.Property_tbl.Price, 
                         dbo.Property_tbl.PriceUnit, dbo.View_Login_Profile.UserId, dbo.View_Login_Profile.FirstName, dbo.View_Login_Profile.LastName, dbo.View_Login_Profile.EmailId, 
                         dbo.View_Login_Profile.ContactNo, dbo.Property_tbl.CreatedOn, dbo.Property_tbl.PropertyFor, dbo.Property_tbl.Description, dbo.Property_tbl.Area, 
                         dbo.AreaUnit_tbl.AreaUnitName AS AreaUnit, dbo.Property_tbl.Property_Status, dbo.Property_tbl.Property_Title, dbo.Property_tbl.Featured, 
                         dbo.Property_tbl.IsSold
FROM            dbo.Property_tbl INNER JOIN
                         dbo.PropertyType_tbl ON dbo.Property_tbl.PropertyTypeId = dbo.PropertyType_tbl.PropertyTypeId LEFT OUTER JOIN
                         dbo.AreaUnit_tbl ON dbo.Property_tbl.AreaUnit = dbo.AreaUnit_tbl.UnitId LEFT OUTER JOIN
                         dbo.View_Login_Profile ON dbo.Property_tbl.CreatedBy = dbo.View_Login_Profile.UserId LEFT OUTER JOIN
                         dbo.PropertyAgeMaster_tbl ON dbo.Property_tbl.PAgeId = dbo.PropertyAgeMaster_tbl.PAgeId




GO
/****** Object:  View [dbo].[View_Feature_PM]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Feature_PM]
AS
SELECT        dbo.Property_Feature_Mapping.FeatureValue, dbo.FeatureMaster.FeatureId, dbo.FeatureMaster.FeatureName, dbo.FeatureMaster.FeatureType, 
                         dbo.FeatureMaster.FeatureCatId, dbo.FeatureMaster.IsDefault, dbo.Property_Feature_Mapping.PropertyId
FROM            dbo.FeatureMaster INNER JOIN
                         dbo.Property_Feature_Mapping ON dbo.FeatureMaster.FeatureId = dbo.Property_Feature_Mapping.FeatureId




GO
/****** Object:  View [dbo].[View_Property_List]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Property_List]
AS
SELECT        PropertyId, Address, City, State, PostCode, Video, Contact, PropertyTypeId, FrontImage, PropertyType, CreatedBy, PropertyAge, Latitude, Longitude, FurnishedStatus, 
                         Price, PriceUnit, UserId, FirstName, LastName, EmailId, ContactNo, CreatedOn, PropertyFor, Description, Area, AreaUnit, Property_Status, ISNULL
                             ((SELECT        FeatureValue
                                 FROM            dbo.View_Feature_PM
                                 WHERE        (PropertyId = p.PropertyId) AND (FeatureName = 'Beds')), 0) AS Beds, ISNULL
                             ((SELECT        FeatureValue
                                 FROM            dbo.View_Feature_PM AS View_Feature_PM_1
                                 WHERE        (PropertyId = p.PropertyId) AND (FeatureName = 'Baths')), 0) AS Baths, Property_Title, Featured, IsSold
FROM            dbo.View_SearchProperty AS p




GO
/****** Object:  View [dbo].[View_Login]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Login]
AS
SELECT     dbo.User_Type.UserTypeName, dbo.User_Type.Uid, dbo.Login_Table.LoginId, dbo.Login_Table.UserId, dbo.Login_Table.EmailId, dbo.Login_Table.FirstName, 
                      dbo.Login_Table.LastName, dbo.Login_Table.Password, dbo.Login_Table.Status
FROM         dbo.Login_Table INNER JOIN
                      dbo.User_Type ON dbo.Login_Table.Uid = dbo.User_Type.Uid




GO
/****** Object:  View [dbo].[View_Event_List]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Event_List]
AS
SELECT        dbo.Events_Table.EventId, dbo.Events_Table.Description, dbo.Events_Table.IsActive, dbo.Events_Table.Entry_Date, dbo.Events_Table.CreatedBy, 
                         dbo.View_Login.FirstName, dbo.View_Login.LastName, dbo.View_Login.EmailId, dbo.View_Login.UserTypeName, dbo.Events_Table.ShownType, 
                         dbo.Events_Table.ShowingDay, dbo.Events_Table.Start_Date, dbo.Events_Table.End_Date, dbo.Events_Table.Start_Time, dbo.Events_Table.End_Time, 
                         dbo.Events_Table.Event_Type, dbo.Events_Table.EventTitle, dbo.Events_Table.PropertyId, dbo.Events_Table.DisplayStatus
FROM            dbo.Events_Table LEFT OUTER JOIN
                         dbo.View_Login ON dbo.Events_Table.CreatedBy = dbo.View_Login.UserId




GO
/****** Object:  View [dbo].[View_Upcoming_Event]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Upcoming_Event]
AS
SELECT        dbo.Events_Table.EventId, dbo.Events_Table.Description, dbo.Events_Table.IsActive, dbo.Events_Table.Entry_Date, dbo.Events_Table.CreatedBy, 
                         dbo.View_Login.FirstName, dbo.View_Login.LastName, dbo.View_Login.EmailId, dbo.View_Login.UserTypeName, dbo.Events_Table.ShowingDay, 
                         dbo.Events_Table.Start_Date, dbo.Events_Table.End_Date, dbo.Events_Table.Start_Time, dbo.Events_Table.End_Time, dbo.Events_Table.Event_Type, 
                         dbo.Events_Table.EventTitle, dbo.Events_Table.PropertyId, dbo.Events_Table.DisplayStatus, dbo.Property_tbl.Address, dbo.Property_tbl.City, 
                         dbo.Property_tbl.State, dbo.Property_tbl.PostCode, dbo.Property_tbl.Latitude, dbo.Property_tbl.Longitude, dbo.Property_tbl.MLSNumber, 
                         dbo.Events_Table.ShownType, dbo.WeekDay_tbl.WeekDayName, (CASE WHEN ShownType = 'EVERY' THEN DateAdd(dd, (ShowingDay - (DATEPART(DW, GetDate()) 
                         - 1)), GETDATE()) ELSE [Start_Date] END) AS ComingDate
FROM            dbo.Events_Table INNER JOIN
                         dbo.Property_tbl ON dbo.Events_Table.PropertyId = dbo.Property_tbl.PropertyId INNER JOIN
                         dbo.View_Login ON dbo.Events_Table.CreatedBy = dbo.View_Login.UserId LEFT OUTER JOIN
                         dbo.WeekDay_tbl ON dbo.Events_Table.ShowingDay = dbo.WeekDay_tbl.Week_Day




GO
/****** Object:  View [dbo].[ViewPropertyDetail]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ViewPropertyDetail]
AS
SELECT        dbo.Property_tbl.PropertyId, dbo.Property_tbl.Address AS Epc, dbo.Property_tbl.City AS PLatitude, dbo.Property_tbl.State AS PLongitude, 
                         dbo.Property_tbl.PostCode AS NoOfBedRoom, dbo.Property_tbl.Video AS Garden, dbo.Property_tbl.Contact AS Parking, dbo.Property_tbl.PropertyTypeId, 
                         dbo.Property_tbl.FrontImage, dbo.PropertyType_tbl.PropertyType, dbo.Property_tbl.CreatedBy, dbo.PropertyAgeMaster_tbl.PropertyAge, dbo.Property_tbl.Latitude, 
                         dbo.Property_tbl.Longitude, dbo.Property_tbl.FurnishedStatus, dbo.Property_tbl.Price AS Country, dbo.Property_tbl.PriceUnit, dbo.View_Login_Profile.UserId, 
                         dbo.View_Login_Profile.FirstName, dbo.View_Login_Profile.LastName, dbo.View_Login_Profile.EmailId, dbo.View_Login_Profile.ContactNo, 
                         dbo.Property_tbl.CreatedOn, dbo.Property_tbl.PropertyFor, dbo.Property_tbl.Description, dbo.Property_tbl.Area, dbo.AreaUnit_tbl.AreaUnitName AS AreaUnit, 
                         dbo.Property_tbl.Property_Status, dbo.Property_tbl.Property_Title, dbo.Property_Images.PrpertyImage
FROM            dbo.Property_tbl INNER JOIN
                         dbo.PropertyType_tbl ON dbo.Property_tbl.PropertyTypeId = dbo.PropertyType_tbl.PropertyTypeId INNER JOIN
                         dbo.Property_Images ON dbo.Property_tbl.PropertyId = dbo.Property_Images.PropertyId LEFT OUTER JOIN
                         dbo.AreaUnit_tbl ON dbo.Property_tbl.AreaUnit = dbo.AreaUnit_tbl.UnitId LEFT OUTER JOIN
                         dbo.View_Login_Profile ON dbo.Property_tbl.CreatedBy = dbo.View_Login_Profile.UserId LEFT OUTER JOIN
                         dbo.PropertyAgeMaster_tbl ON dbo.Property_tbl.PAgeId = dbo.PropertyAgeMaster_tbl.PAgeId




GO
/****** Object:  View [dbo].[View_RecentSearch]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_RecentSearch]
AS
Select a.SrlNo,a.UniqueId,a.SearchId,a.SearchType,b.PropertyAge as sname from  dbo.RecentSearchTbl a join dbo.PropertyAgeMaster_tbl b on a.SearchId=b.PAgeId where a.SearchType='AGE'
Union
Select a.SrlNo,a.UniqueId,a.SearchId,a.SearchType,b.FeatureName as sname from  dbo.RecentSearchTbl a join dbo.FeatureMaster b on a.SearchId=b.FeatureId where a.SearchType='FEATURE'
Union
Select a.SrlNo,a.UniqueId,a.SearchId,a.SearchType,b.Characteristic as sname from  dbo.RecentSearchTbl a join dbo.PropertyCharacteristics b on a.SearchId=b.CharId where a.SearchType='CHARACTER'
Union
Select a.SrlNo,a.UniqueId,a.SearchId,a.SearchType,b.PropertyType as sname from  dbo.RecentSearchTbl a join dbo.PropertyType_tbl b on a.SearchId=b.PropertyTypeId where a.SearchType='PTYPE'




GO
/****** Object:  View [dbo].[View_RecentSearchMapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_RecentSearchMapping]
AS
Select  UniqueId, SearchId, SearchType,A.PropertyId from dbo.View_RecentSearch  R join dbo.Propert_Age_Mapping A on R.SearchId=A.PAgeId where R.SearchType='AGE'
Union
Select  UniqueId, SearchId, SearchType,A.PropertyId from dbo.View_RecentSearch  R join dbo.Property_Feature_Mapping A on R.SearchId=A.FeatureId where R.SearchType='FEATURE'
Union
Select  UniqueId, SearchId, SearchType,A.PropertyId from dbo.View_RecentSearch  R join dbo.Property_Characteristic_Mapping A on R.SearchId=A.CharId where R.SearchType='CHARACTER'
Union
Select  UniqueId, SearchId, SearchType,A.PropertyId from dbo.View_RecentSearch  R join dbo.Property_tbl A on R.SearchId=A.PropertyTypeId where R.SearchType='PTYPE'




GO
/****** Object:  View [dbo].[View_PType_FMapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_PType_FMapping]
AS
SELECT        dbo.FeatureMaster.FeatureName, dbo.FeatureMaster.FeatureType, dbo.FeatureCategory.FeatureCatId, dbo.FeatureCategory.FeatureCategory, 
                         dbo.FeatureCategory.EntryDate, dbo.ProprtyType_Feature_Mapping.PropertyTypeId, dbo.FeatureMaster.FeatureId
FROM            dbo.FeatureCategory INNER JOIN
                         dbo.FeatureMaster ON dbo.FeatureCategory.FeatureCatId = dbo.FeatureMaster.FeatureCatId INNER JOIN
                         dbo.ProprtyType_Feature_Mapping ON dbo.FeatureMaster.FeatureId = dbo.ProprtyType_Feature_Mapping.FeatureId




GO
/****** Object:  View [dbo].[View_Propert_wise_features]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Propert_wise_features]
AS
SELECT        dbo.View_PType_FMapping.FeatureName, dbo.View_PType_FMapping.FeatureType, dbo.View_PType_FMapping.FeatureCatId, 
                         dbo.View_PType_FMapping.FeatureCategory, dbo.Property_tbl.PropertyId, dbo.View_PType_FMapping.FeatureId
FROM            dbo.View_PType_FMapping INNER JOIN
                         dbo.Property_tbl ON dbo.View_PType_FMapping.PropertyTypeId = dbo.Property_tbl.PropertyTypeId




GO
/****** Object:  View [dbo].[View_AgentContact_Property]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_AgentContact_Property]
AS
SELECT        dbo.PropertyType_tbl.PropertyType, dbo.PropertyAgeMaster_tbl.PropertyAge, dbo.Property_tbl.PropertyId, dbo.Property_tbl.PropertyFor, 
                         dbo.Property_tbl.PropertyTypeId, dbo.Property_tbl.Property_Title, dbo.Property_tbl.FrontImage, dbo.Property_tbl.Price, dbo.Property_tbl.PriceUnit, 
                         dbo.Property_tbl.Area, dbo.Property_tbl.PAgeId, dbo.Property_tbl.Description, dbo.Property_tbl.Address, dbo.Property_tbl.City, dbo.Property_tbl.State, 
                         dbo.Property_tbl.PostCode, dbo.Property_tbl.Latitude, dbo.Property_tbl.Longitude, dbo.Property_tbl.Video, dbo.Property_tbl.Contact, dbo.Property_tbl.CreatedOn, 
                         dbo.Property_tbl.FurnishedStatus, dbo.Property_tbl.Property_Status, dbo.AreaUnit_tbl.AreaUnitName, dbo.Property_tbl.AreaUnit, dbo.AgentContact_tbl.Name, 
                         dbo.AgentContact_tbl.Phone, dbo.AgentContact_tbl.Email, dbo.AgentContact_tbl.Message, dbo.AgentContact_tbl.Entry_Date, dbo.AgentContact_tbl.AgentContact_Id, 
                         dbo.Property_tbl.IsSold, dbo.Property_tbl.CreatedBy, dbo.Login_Table.FirstName, dbo.Login_Table.LastName, dbo.Login_Table.EmailId
FROM            dbo.Login_Table INNER JOIN
                         dbo.Profile_Info ON dbo.Login_Table.UserId = dbo.Profile_Info.Profile_Id RIGHT OUTER JOIN
                         dbo.AgentContact_tbl INNER JOIN
                         dbo.Property_tbl ON dbo.AgentContact_tbl.PropertyId = dbo.Property_tbl.PropertyId ON dbo.Profile_Info.Profile_Id = dbo.Property_tbl.CreatedBy LEFT OUTER JOIN
                         dbo.AreaUnit_tbl ON dbo.Property_tbl.AreaUnit = dbo.AreaUnit_tbl.UnitId LEFT OUTER JOIN
                         dbo.PropertyType_tbl ON dbo.Property_tbl.PropertyTypeId = dbo.PropertyType_tbl.PropertyTypeId LEFT OUTER JOIN
                         dbo.PropertyAgeMaster_tbl ON dbo.Property_tbl.PAgeId = dbo.PropertyAgeMaster_tbl.PAgeId




GO
/****** Object:  View [dbo].[View_ChatLoginProfile]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_ChatLoginProfile]
AS
SELECT        dbo.Login_Table.UserId, dbo.Login_Table.EmailId, dbo.Login_Table.FirstName, dbo.Login_Table.LastName, dbo.Login_Table.LoginId, dbo.Login_Table.Uid, 
                         dbo.Login_Table.Status, dbo.Login_Table.Email_verified, dbo.Login_Table.Last_visited, dbo.Login_Table.googleId, dbo.Profile_Info.ProfileSrl, 
                         dbo.Profile_Info.Profile_Id, dbo.Profile_Info.Photo, dbo.Profile_Info.Gender, dbo.Profile_Info.Entry_Date, dbo.Profile_Info.Last_Modified_Date, 
                         dbo.Profile_Info.CreatedBy
FROM            dbo.Profile_Info INNER JOIN
                         dbo.Login_Table ON dbo.Profile_Info.Profile_Id = dbo.Login_Table.UserId

GO
/****** Object:  View [dbo].[View_Classfied_Category]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Classfied_Category]
AS
SELECT        dbo.ClassifiedAds_tbl.ClassifiedId, dbo.ClassifiedAds_tbl.Title, dbo.ClassifiedAds_tbl.Pay_Type, dbo.ClassifiedAds_tbl.Amount, dbo.ClassifiedAds_tbl.Image, 
                         dbo.ClassifiedAds_tbl.Description, dbo.ClassifiedAds_tbl.Contact_Name, dbo.ClassifiedAds_tbl.Contact_Email, dbo.ClassifiedAds_tbl.Contact_Phone, 
                         dbo.ClassifiedAds_tbl.Contact_location, dbo.ClassifiedAds_tbl.ClassifiedEntry_Date, dbo.ClassifiedAds_tbl.ClassifiedStatus, dbo.ClassifiedAds_tbl.Catid, 
                         dbo.ClassifiedAds_tbl.Latitude, dbo.ClassifiedAds_tbl.Longitude, dbo.ClassifiedCategory.CategoryName
FROM            dbo.ClassifiedAds_tbl LEFT OUTER JOIN
                         dbo.ClassifiedCategory ON dbo.ClassifiedAds_tbl.Catid = dbo.ClassifiedCategory.Catid

GO
/****** Object:  View [dbo].[View_Contact_Property]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Contact_Property]
AS
SELECT        dbo.AgentContact_tbl.*, dbo.Property_tbl.Property_Title, dbo.Property_tbl.PropertyFor
FROM            dbo.AgentContact_tbl LEFT OUTER JOIN
                         dbo.Property_tbl ON dbo.AgentContact_tbl.PropertyId = dbo.Property_tbl.PropertyId

GO
/****** Object:  View [dbo].[View_Event_Weekday]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Event_Weekday]
AS
SELECT        dbo.WeekDay_tbl.WeekDayName, dbo.Events_Table.EventId, dbo.Events_Table.EventTitle, dbo.Events_Table.Description, dbo.Events_Table.ShownType, 
                         dbo.Events_Table.ShowingDay, dbo.Events_Table.Start_Date, dbo.Events_Table.End_Date, dbo.Events_Table.Start_Time, dbo.Events_Table.End_Time, 
                         dbo.Events_Table.IsActive, dbo.Events_Table.Entry_Date, dbo.Events_Table.CreatedBy, dbo.Events_Table.Event_Type, dbo.Events_Table.PropertyId
FROM            dbo.Events_Table LEFT OUTER JOIN
                         dbo.WeekDay_tbl ON dbo.Events_Table.ShowingDay = dbo.WeekDay_tbl.Week_Day




GO
/****** Object:  View [dbo].[View_Favourite_Property]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Favourite_Property]
AS
SELECT        dbo.PropertyType_tbl.PropertyType, dbo.PropertyAgeMaster_tbl.PropertyAge, dbo.Property_tbl.PropertyFor, dbo.Property_tbl.PropertyTypeId, 
                         dbo.Property_tbl.Property_Title, dbo.Property_tbl.FrontImage, dbo.Property_tbl.Price, dbo.Property_tbl.PriceUnit, dbo.Property_tbl.Area, dbo.Property_tbl.PAgeId, 
                         dbo.Property_tbl.Description, dbo.Property_tbl.Address, dbo.Property_tbl.City, dbo.Property_tbl.State, dbo.Property_tbl.PostCode, dbo.Property_tbl.Latitude, 
                         dbo.Property_tbl.Longitude, dbo.Property_tbl.Video, dbo.Property_tbl.Contact, dbo.Property_tbl.CreatedOn, dbo.Property_tbl.FurnishedStatus, 
                         dbo.Property_tbl.Property_Status, dbo.AreaUnit_tbl.AreaUnitName, dbo.Property_tbl.AreaUnit, dbo.Property_tbl.IsSold, dbo.Property_tbl.CreatedBy, 
                         dbo.Favourite_Property.Profile_Id, dbo.Property_tbl.PropertyId
FROM            dbo.Profile_Info INNER JOIN
                         dbo.Favourite_Property INNER JOIN
                         dbo.Property_tbl ON dbo.Favourite_Property.PropertyId = dbo.Property_tbl.PropertyId ON 
                         dbo.Profile_Info.Profile_Id = dbo.Favourite_Property.Profile_Id LEFT OUTER JOIN
                         dbo.AreaUnit_tbl ON dbo.Property_tbl.AreaUnit = dbo.AreaUnit_tbl.UnitId LEFT OUTER JOIN
                         dbo.PropertyType_tbl ON dbo.Property_tbl.PropertyTypeId = dbo.PropertyType_tbl.PropertyTypeId LEFT OUTER JOIN
                         dbo.PropertyAgeMaster_tbl ON dbo.Property_tbl.PAgeId = dbo.PropertyAgeMaster_tbl.PAgeId




GO
/****** Object:  View [dbo].[View_Feature_Cat_mapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Feature_Cat_mapping]
AS
SELECT        dbo.FeatureCategory.FeatureCatId, dbo.FeatureCategory.FeatureCategory, dbo.FeatureMaster.FeatureId, dbo.FeatureMaster.FeatureName, 
                         dbo.FeatureMaster.FeatureType, dbo.FeatureMaster.IsDefault
FROM            dbo.FeatureCategory INNER JOIN
                         dbo.FeatureMaster ON dbo.FeatureCategory.FeatureCatId = dbo.FeatureMaster.FeatureCatId




GO
/****** Object:  View [dbo].[View_Propertydtl]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Propertydtl]
AS
SELECT        dbo.PropertyType_tbl.PropertyType, dbo.PropertyAgeMaster_tbl.PropertyAge, dbo.Property_tbl.PropertyId, dbo.Property_tbl.PropertyFor, 
                         dbo.Property_tbl.PropertyTypeId, dbo.Property_tbl.Property_Title, dbo.Property_tbl.FrontImage, dbo.Property_tbl.Price, dbo.Property_tbl.PriceUnit, 
                         dbo.Property_tbl.Area, dbo.Property_tbl.PAgeId, dbo.Property_tbl.Description, dbo.Property_tbl.Address, dbo.Property_tbl.City, dbo.Property_tbl.State, 
                         dbo.Property_tbl.PostCode, dbo.Property_tbl.Latitude, dbo.Property_tbl.Longitude, dbo.Property_tbl.Video, dbo.Property_tbl.Contact, dbo.Property_tbl.CreatedOn, 
                         dbo.Property_tbl.FurnishedStatus, dbo.Property_tbl.Property_Status, AreaUnit_tbl_1.AreaUnitName, dbo.Profile_Info.ContactNo, dbo.Profile_Info.Photo, 
                         dbo.Profile_Info.Address AS Seller_Address, dbo.Profile_Info.City AS Seller_City, dbo.Profile_Info.Zip, dbo.Login_Table.FirstName, dbo.Login_Table.LastName, 
                         dbo.Login_Table.EmailId, dbo.Profile_Info.CreatedBy, dbo.Property_tbl.AreaUnit, dbo.Login_Table.Uid, dbo.Property_tbl.IsSold, dbo.Profile_Info.Profile_Id, 
                         dbo.Property_tbl.MLSNumber, dbo.Property_tbl.LOTArea, dbo.Property_tbl.LOTAreaUnit, dbo.Property_tbl.YearBuilt, 
                         dbo.AreaUnit_tbl.AreaUnitName AS LotAreaUnitName, dbo.Profile_Info.State AS Expr1, dbo.Profile_Info.Country, dbo.Profile_Info.Gender, dbo.Profile_Info.DOB, 
                         dbo.Profile_Info.Latitude AS Expr2, dbo.Profile_Info.Longitude AS Expr3
FROM            dbo.AreaUnit_tbl RIGHT OUTER JOIN
                         dbo.Property_tbl ON dbo.AreaUnit_tbl.UnitId = dbo.Property_tbl.LOTAreaUnit LEFT OUTER JOIN
                         dbo.Profile_Info INNER JOIN
                         dbo.Login_Table ON dbo.Profile_Info.Profile_Id = dbo.Login_Table.UserId ON dbo.Property_tbl.CreatedBy = dbo.Profile_Info.Profile_Id LEFT OUTER JOIN
                         dbo.AreaUnit_tbl AS AreaUnit_tbl_1 ON dbo.Property_tbl.AreaUnit = AreaUnit_tbl_1.UnitId LEFT OUTER JOIN
                         dbo.PropertyType_tbl ON dbo.Property_tbl.PropertyTypeId = dbo.PropertyType_tbl.PropertyTypeId LEFT OUTER JOIN
                         dbo.PropertyAgeMaster_tbl ON dbo.Property_tbl.PAgeId = dbo.PropertyAgeMaster_tbl.PAgeId

GO
/****** Object:  View [dbo].[View_Review_login_profile]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Review_login_profile]
AS
SELECT        dbo.Login_Table.LoginId, dbo.Login_Table.Uid, dbo.Login_Table.EmailId, dbo.Login_Table.FirstName, dbo.Login_Table.LastName, dbo.Login_Table.Password, 
                         dbo.Login_Table.Status, dbo.User_Type.UserTypeName, dbo.Profile_Info.ProfileSrl, dbo.Profile_Info.Profile_Id, dbo.Profile_Info.ContactNo, dbo.Profile_Info.Address, 
                         dbo.Profile_Info.City, dbo.Profile_Info.State, dbo.Profile_Info.Country, dbo.Profile_Info.Zip, dbo.Profile_Info.Photo, dbo.Profile_Info.DOB, dbo.Profile_Info.Gender, 
                         dbo.Profile_Info.Entry_Date, dbo.Profile_Info.Last_Modified_Date, dbo.Profile_Info.CreatedBy, dbo.User_Type.DisplayName, dbo.Profile_Info.AboutMe, 
                         dbo.Profile_Info.CCode, dbo.Agent_Review_tbl.ReviewId, dbo.Agent_Review_tbl.Rating, dbo.Agent_Review_tbl.ReviewText, dbo.Agent_Review_tbl.AgentId, 
                         dbo.Agent_Review_tbl.ReviewDate, dbo.Agent_Review_tbl.UserId, dbo.Profile_Info.Latitude, dbo.Profile_Info.Longitude
FROM            dbo.User_Type INNER JOIN
                         dbo.Login_Table ON dbo.User_Type.Uid = dbo.Login_Table.Uid RIGHT OUTER JOIN
                         dbo.Agent_Review_tbl ON dbo.Login_Table.UserId = dbo.Agent_Review_tbl.UserId LEFT OUTER JOIN
                         dbo.Profile_Info ON dbo.Login_Table.UserId = dbo.Profile_Info.Profile_Id




GO
/****** Object:  View [dbo].[View_sociallink_mapping]    Script Date: 22 Dec 2017 2:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_sociallink_mapping]
AS
SELECT        dbo.SociallinkMapping_tbl.Id, dbo.SociallinkMapping_tbl.SocialId, dbo.SociallinkMapping_tbl.UserId, dbo.SociallinkMapping_tbl.Social_link, 
                         dbo.SociallinkMapping_tbl.Entrydate, dbo.SociallinkMaster_tbl.Social_Icon, dbo.SociallinkMaster_tbl.Social_Site, dbo.SociallinkMapping_tbl.SMID
FROM            dbo.SociallinkMaster_tbl RIGHT OUTER JOIN
                         dbo.SociallinkMapping_tbl ON dbo.SociallinkMaster_tbl.SocialId = dbo.SociallinkMapping_tbl.SocialId

GO
INSERT [dbo].[Admin] ([Id], [username], [Password]) VALUES (1, N'Admin', N'123456')
INSERT [dbo].[Ads_tbl] ([AdId], [Ad_Image], [Ad_Description], [City], [ZipCode], [Link], [EntryDate], [Status]) VALUES (N'AD727390118', N'27102017133532960_1.jpg', N'<p>demo</p', N'Los Altos Hills', N'CA 94022', NULL, N'Oct 27 2017  1:35PM', 1)
INSERT [dbo].[Ads_tbl] ([AdId], [Ad_Image], [Ad_Description], [City], [ZipCode], [Link], [EntryDate], [Status]) VALUES (N'AD741222027', N'27102017145624142_2.jpg', NULL, N'New York', N'NY7001', N'https://www.google.co.in/?gfe_rd=cr&dcr=0&ei=KcwKWuisLcPSqAHOjY-QAw', N'Oct 27 2017  2:56PM', 1)
INSERT [dbo].[Ads_tbl] ([AdId], [Ad_Image], [Ad_Description], [City], [ZipCode], [Link], [EntryDate], [Status]) VALUES (N'AD940956891', N'02122017094050859_3.jpg', NULL, N'Asansol', N'713302', NULL, N'Dec  2 2017  9:39AM', 1)
INSERT [dbo].[Agent_Picture] ([PhotoId], [Photo_Title], [Photo], [Photo_Entrydate], [Profile_Id]) VALUES (N'P694946362', N'Test new demo desc', N'15082017223950116_10.jpg', CAST(0x0000A7D001757D66 AS DateTime), N'U831603621')
INSERT [dbo].[Agent_Picture] ([PhotoId], [Photo_Title], [Photo], [Photo_Entrydate], [Profile_Id]) VALUES (N'P713442815', N'OUR LATEST PROJECT', N'26072017232545458_9.jpg', CAST(0x0000A7BC01821A65 AS DateTime), N'U831603621')
INSERT [dbo].[Agent_Picture] ([PhotoId], [Photo_Title], [Photo], [Photo_Entrydate], [Profile_Id]) VALUES (N'P817071355', N'Test prop new desc', N'15082017224131937_10.jpg', CAST(0x0000A7D00175F4B7 AS DateTime), N'U831603621')
INSERT [dbo].[Agent_Picture] ([PhotoId], [Photo_Title], [Photo], [Photo_Entrydate], [Profile_Id]) VALUES (N'P895564538', N'Test Pic', N'25082017071515271_12.jpg', CAST(0x0000A7DA00778B9B AS DateTime), N'U333611123')
INSERT [dbo].[Agent_Picture] ([PhotoId], [Photo_Title], [Photo], [Photo_Entrydate], [Profile_Id]) VALUES (N'P971697504', N'test', N'18082017102425749_11.jpg', CAST(0x0000A7D300AB80EF AS DateTime), N'U100955369')
INSERT [dbo].[Agent_Picture] ([PhotoId], [Photo_Title], [Photo], [Photo_Entrydate], [Profile_Id]) VALUES (N'P977367111', N'Test', N'01122017095627518_10.jpg', CAST(0x0000A83C00A3D630 AS DateTime), N'U831603621')
INSERT [dbo].[Agent_Picture] ([PhotoId], [Photo_Title], [Photo], [Photo_Entrydate], [Profile_Id]) VALUES (N'P984448498', N'OUR LATEST SOLD HOME', N'25082017080205886_14.jpg', CAST(0x0000A7DA00846946 AS DateTime), N'U100955369')
SET IDENTITY_INSERT [dbo].[Agent_Review_tbl] ON 

INSERT [dbo].[Agent_Review_tbl] ([ReviewId], [Rating], [ReviewText], [AgentId], [UserId], [ReviewDate]) VALUES (1, 3, N'Lorem Ipsum is simply dummy text of the printing and typesetting industry.', N'U679844771', N'U679844771', CAST(0x0000A7840052904F AS DateTime))
INSERT [dbo].[Agent_Review_tbl] ([ReviewId], [Rating], [ReviewText], [AgentId], [UserId], [ReviewDate]) VALUES (2, 2, N'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. ', N'U679844771', N'U831603621', CAST(0x0000A784005483F4 AS DateTime))
INSERT [dbo].[Agent_Review_tbl] ([ReviewId], [Rating], [ReviewText], [AgentId], [UserId], [ReviewDate]) VALUES (3, 5, N'Test', N'U831603621', N'U831603621', CAST(0x0000A784006748A7 AS DateTime))
INSERT [dbo].[Agent_Review_tbl] ([ReviewId], [Rating], [ReviewText], [AgentId], [UserId], [ReviewDate]) VALUES (4, 3, N'Test Review', N'U831603621', N'U014877963', CAST(0x0000A7A80068DF5C AS DateTime))
INSERT [dbo].[Agent_Review_tbl] ([ReviewId], [Rating], [ReviewText], [AgentId], [UserId], [ReviewDate]) VALUES (5, 5, N'123', N'U616637881', N'U831603621', CAST(0x0000A7AF00C92AD2 AS DateTime))
SET IDENTITY_INSERT [dbo].[Agent_Review_tbl] OFF
INSERT [dbo].[Agent_Video] ([VideoId], [Video_Title], [File_Type], [Video], [Video_Entrydate], [Profile_Id]) VALUES (N'V066474906', N'WILLIAM VIDEO', N'Youtube', N'EUkXB_wJSkI', CAST(0x0000A7DA00D653A2 AS DateTime), N'U100955369')
INSERT [dbo].[Agent_Video] ([VideoId], [Video_Title], [File_Type], [Video], [Video_Entrydate], [Profile_Id]) VALUES (N'V107156177', N'Test Youtube Video', N'Youtube', N'-qdFcxHUWwI', CAST(0x0000A7A20062C6DF AS DateTime), NULL)
INSERT [dbo].[Agent_Video] ([VideoId], [Video_Title], [File_Type], [Video], [Video_Entrydate], [Profile_Id]) VALUES (N'V544098713', N'Test Videos', N'System', N'30062017055826700_2.mp4', CAST(0x0000A7A200627333 AS DateTime), NULL)
INSERT [dbo].[Agent_Video] ([VideoId], [Video_Title], [File_Type], [Video], [Video_Entrydate], [Profile_Id]) VALUES (N'V663340323', N'Test Video', N'System', N'25082017071542974_13.mp4', CAST(0x0000A7DA0077AC0F AS DateTime), N'U333611123')
INSERT [dbo].[Agent_Video] ([VideoId], [Video_Title], [File_Type], [Video], [Video_Entrydate], [Profile_Id]) VALUES (N'V795110932', N'Test New prop Video', N'System', N'28082017232210482_15.mp4', CAST(0x0000A7DD01811E35 AS DateTime), N'U831603621')
INSERT [dbo].[AgentContact_tbl] ([AgentContact_Id], [Name], [Phone], [Email], [Message], [PropertyId], [Profile_Id], [Entry_Date], [Status], [AgentId]) VALUES (N'CI022271836', N'Ginee', N'874512', N'aa@a.com', N'test', NULL, N'U983041850', CAST(0x0000A7B50111633D AS DateTime), N'True', NULL)
INSERT [dbo].[AgentContact_tbl] ([AgentContact_Id], [Name], [Phone], [Email], [Message], [PropertyId], [Profile_Id], [Entry_Date], [Status], [AgentId]) VALUES (N'CI100753034', N'Jhon Doe', N'9876543210', N'apx510@gmail.com', N'TEST CONTAC REQUEST FOR JOHN', NULL, N'U831603621', CAST(0x0000A7F4008A7820 AS DateTime), N'True', NULL)
INSERT [dbo].[AgentContact_tbl] ([AgentContact_Id], [Name], [Phone], [Email], [Message], [PropertyId], [Profile_Id], [Entry_Date], [Status], [AgentId]) VALUES (N'CI306883605', N'Test Test', N'876543210', N'test@goigi.net', N'Demo Test', N'P612705080', NULL, CAST(0x0000A7B601074563 AS DateTime), N'True', NULL)
INSERT [dbo].[AgentContact_tbl] ([AgentContact_Id], [Name], [Phone], [Email], [Message], [PropertyId], [Profile_Id], [Entry_Date], [Status], [AgentId]) VALUES (N'CI488933039', N'aaa', N'1263465654', N'aa@a.com', N'aa', NULL, N'U983041850', CAST(0x0000A7B50113BEDC AS DateTime), N'True', NULL)
INSERT [dbo].[AgentContact_tbl] ([AgentContact_Id], [Name], [Phone], [Email], [Message], [PropertyId], [Profile_Id], [Entry_Date], [Status], [AgentId]) VALUES (N'CI625586772', N'aaa', N'13215', N'aas@a.com', N'test', NULL, N'U983041850', CAST(0x0000A7B501146191 AS DateTime), N'True', NULL)
INSERT [dbo].[AgentContact_tbl] ([AgentContact_Id], [Name], [Phone], [Email], [Message], [PropertyId], [Profile_Id], [Entry_Date], [Status], [AgentId]) VALUES (N'CI718760783', N'ccc', N'132612564', N'cc@goigi.net', N'xx', NULL, N'U983041850', CAST(0x0000A7B50114BFA6 AS DateTime), N'True', NULL)
INSERT [dbo].[AgentContact_tbl] ([AgentContact_Id], [Name], [Phone], [Email], [Message], [PropertyId], [Profile_Id], [Entry_Date], [Status], [AgentId]) VALUES (N'CI770615841', N'Jhon', N'6542310', N'aa@a.com', N'aa', NULL, N'U782478597', CAST(0x0000A7B601172248 AS DateTime), N'True', NULL)
INSERT [dbo].[AgentContact_tbl] ([AgentContact_Id], [Name], [Phone], [Email], [Message], [PropertyId], [Profile_Id], [Entry_Date], [Status], [AgentId]) VALUES (N'CI846541163', N'lyndaa', N'9876543210', N'test@gmail.com', N'test mail', NULL, N'U983041850', CAST(0x0000A7B5010FFB40 AS DateTime), N'True', NULL)
INSERT [dbo].[AgentContact_tbl] ([AgentContact_Id], [Name], [Phone], [Email], [Message], [PropertyId], [Profile_Id], [Entry_Date], [Status], [AgentId]) VALUES (N'CI895434696', N'jamesq', N'777777777', N'james@gmail.com', N'qwer', NULL, N'U983041850', CAST(0x0000A7B50112EA3B AS DateTime), N'True', NULL)
INSERT [dbo].[AgentContact_tbl] ([AgentContact_Id], [Name], [Phone], [Email], [Message], [PropertyId], [Profile_Id], [Entry_Date], [Status], [AgentId]) VALUES (N'CI949408453', N'aaaa', N'9876543210', N'aa@a.com', N'aaaaaaaa', NULL, N'U983041850', CAST(0x0000A7B501107834 AS DateTime), N'True', NULL)
SET IDENTITY_INSERT [dbo].[Area_tbl] ON 

INSERT [dbo].[Area_tbl] ([AreaId], [Area]) VALUES (5, N'Angel')
INSERT [dbo].[Area_tbl] ([AreaId], [Area]) VALUES (6, N'Bricklane')
INSERT [dbo].[Area_tbl] ([AreaId], [Area]) VALUES (7, N'Bow')
SET IDENTITY_INSERT [dbo].[Area_tbl] OFF
INSERT [dbo].[AreaUnit_tbl] ([UnitId], [AreaUnitName], [EqvUnitValueinSqrFt], [UnitOfLenth]) VALUES (N'UN311555433', N'SQ. FT.', CAST(45.00 AS Decimal(18, 2)), N'ft')
INSERT [dbo].[AreaUnit_tbl] ([UnitId], [AreaUnitName], [EqvUnitValueinSqrFt], [UnitOfLenth]) VALUES (N'UN438609345', N'ACRE', CAST(43560.00 AS Decimal(18, 2)), N'ACRE')
SET IDENTITY_INSERT [dbo].[Arrange_Viewing] ON 

INSERT [dbo].[Arrange_Viewing] ([Viewing_Id], [Title], [Name], [EmailId], [Primary_Telephone], [Work_Telephone], [MobileNo], [Viewing_Date], [Time_of_Day], [Other_Requirement], [UserId], [PropertyId]) VALUES (1, N'Mr.', N'name', N'john@gmail.com', NULL, NULL, N'9876543210', CAST(0x663B0B00 AS Date), N'No Preference', NULL, N'1', N'PID088090219')
INSERT [dbo].[Arrange_Viewing] ([Viewing_Id], [Title], [Name], [EmailId], [Primary_Telephone], [Work_Telephone], [MobileNo], [Viewing_Date], [Time_of_Day], [Other_Requirement], [UserId], [PropertyId]) VALUES (12, N'Mrs.', N'xssdds', N'sdf@gmail.com', NULL, NULL, N'1425369870', CAST(0x583B0B00 AS Date), N'No Preference', N'dfwerewt hey i am buyer want to buy this property', N'4', N'PID974603615')
INSERT [dbo].[Arrange_Viewing] ([Viewing_Id], [Title], [Name], [EmailId], [Primary_Telephone], [Work_Telephone], [MobileNo], [Viewing_Date], [Time_of_Day], [Other_Requirement], [UserId], [PropertyId]) VALUES (13, N'Dr.', N'Angle', N'angle@gmail.com', N'1425369870', N'9865321470', N'8967064258', CAST(0x583B0B00 AS Date), N'Morning', NULL, N'8', N'PID602612757')
INSERT [dbo].[Arrange_Viewing] ([Viewing_Id], [Title], [Name], [EmailId], [Primary_Telephone], [Work_Telephone], [MobileNo], [Viewing_Date], [Time_of_Day], [Other_Requirement], [UserId], [PropertyId]) VALUES (14, N'Mrs.', N'margret', N'm@gmail.com', N'213654789', N'76524190', N'4152639870', CAST(0x583B0B00 AS Date), N'Morning', N'In liked the property and want to buy it ', N'8', N'PID318482922')
INSERT [dbo].[Arrange_Viewing] ([Viewing_Id], [Title], [Name], [EmailId], [Primary_Telephone], [Work_Telephone], [MobileNo], [Viewing_Date], [Time_of_Day], [Other_Requirement], [UserId], [PropertyId]) VALUES (15, N'Mrs.', N'sample', N's@gmail.com', N'258369', N'258369', N'2583690147', CAST(0x6D3B0B00 AS Date), N'Afternoon', N'sdsdsddsds', N'4', N'PID273197018')
INSERT [dbo].[Arrange_Viewing] ([Viewing_Id], [Title], [Name], [EmailId], [Primary_Telephone], [Work_Telephone], [MobileNo], [Viewing_Date], [Time_of_Day], [Other_Requirement], [UserId], [PropertyId]) VALUES (18, N'Dr.', N'Dave Morean', N'davemm@gmail.com', N'21547896', N'23659814', N'9867068520', CAST(0x6D3B0B00 AS Date), N'Morning', N'Please carry the property document with you for sure...', NULL, N'PID088090219')
INSERT [dbo].[Arrange_Viewing] ([Viewing_Id], [Title], [Name], [EmailId], [Primary_Telephone], [Work_Telephone], [MobileNo], [Viewing_Date], [Time_of_Day], [Other_Requirement], [UserId], [PropertyId]) VALUES (19, N'Dr.', N'Dave Morean', N'davemm@gmail.com', N'125487', N'236598', N'2365981470', CAST(0x6E3B0B00 AS Date), N'Afternoon', N'Accept ', NULL, N'PID088090219')
SET IDENTITY_INSERT [dbo].[Arrange_Viewing] OFF
INSERT [dbo].[ClassifiedAds_tbl] ([ClassifiedId], [Title], [Pay_Type], [Amount], [Image], [Description], [Contact_Name], [Contact_Email], [Contact_Phone], [Contact_location], [ClassifiedEntry_Date], [ClassifiedStatus], [Catid], [Latitude], [Longitude]) VALUES (N'CI287982145', N'Test title', N'Amount', CAST(8000.00 AS Decimal(18, 2)), N'27102017183257555_65.jpg', N'<p>Demo</p>
', N'test name', N'test@gmail.com', N'9876543210', N'Asansol, West Bengal, India', CAST(0x0000A8190131A384 AS DateTime), 1, N'C344598256', 23.6739452, 86.9523954)
INSERT [dbo].[ClassifiedAds_tbl] ([ClassifiedId], [Title], [Pay_Type], [Amount], [Image], [Description], [Contact_Name], [Contact_Email], [Contact_Phone], [Contact_location], [ClassifiedEntry_Date], [ClassifiedStatus], [Catid], [Latitude], [Longitude]) VALUES (N'CI510414226', N'AUTO WORLD BODY & FRAME (OAKLAND)', N'Negotiable', NULL, N'27102017171751142_58.jpg', N'<p>AUTO BODY SHOP OAKLAND</p>
', N'CHOY', NULL, N'5108321668', N'Austin, TX, USA', CAST(0x0000A7F400654539 AS DateTime), 1, N'C792589283', 30.267153, -97.743060799999967)
INSERT [dbo].[ClassifiedAds_tbl] ([ClassifiedId], [Title], [Pay_Type], [Amount], [Image], [Description], [Contact_Name], [Contact_Email], [Contact_Phone], [Contact_location], [ClassifiedEntry_Date], [ClassifiedStatus], [Catid], [Latitude], [Longitude]) VALUES (N'CI904104797', N'LAM''S PLUMBING', N'Negotiable', NULL, N'27102017171800408_59.jpg', N'<p>LOOKING FOR A GREAT PLUMBERS.</p>

<p><span style="font-family: arial; font-size: 14px;">Ng&agrave;y 8/12, Bộ Ch&iacute;nh trị đ&atilde; họp, cho &yacute; kiến về kết quả l&agrave;m việc của 5 Đo&agrave;n kiểm tra việc thực hiện kết luận của Bộ Ch&iacute;nh trị (kh&oacute;a XI) về đẩy mạnh c&ocirc;ng t&aacute;c quy hoạch, lu&acirc;n chuyển c&aacute;n bộ l&atilde;nh đạo, quản l&yacute; đến năm 2020 v&agrave; những năm tiếp theo, gắn với thực hiện Quy chế bổ nhiệm, giới thiệu c&aacute;n bộ ứng cử.</span></p>
', N'LAM', NULL, N'9250000000', N'Durgapur Railway Station Complex, Railway Ground Rail Colony, Durgapur, West Bengal 713201, India', CAST(0x0000A7F40064DDBF AS DateTime), 1, N'C344598256', 23.4943405, 87.3169103)
INSERT [dbo].[ClassifiedCategory] ([Catid], [CategoryName], [Image], [IsActive], [EntryDate]) VALUES (N'C344598256', N'PLUMBING', NULL, 1, CAST(0x0000A7BF0063635B AS DateTime))
INSERT [dbo].[ClassifiedCategory] ([Catid], [CategoryName], [Image], [IsActive], [EntryDate]) VALUES (N'C383043852', N'HANDY MAN', NULL, 1, CAST(0x0000A7D4015AAFE5 AS DateTime))
INSERT [dbo].[ClassifiedCategory] ([Catid], [CategoryName], [Image], [IsActive], [EntryDate]) VALUES (N'C509308135', N'JOBS', NULL, 1, CAST(0x0000A7D4015B0D8A AS DateTime))
INSERT [dbo].[ClassifiedCategory] ([Catid], [CategoryName], [Image], [IsActive], [EntryDate]) VALUES (N'C641409840', N'RESTAURANTS', NULL, 1, CAST(0x0000A7BF0063559F AS DateTime))
INSERT [dbo].[ClassifiedCategory] ([Catid], [CategoryName], [Image], [IsActive], [EntryDate]) VALUES (N'C792589283', N'AUTO REPAIR / AUTO BODY', NULL, 1, CAST(0x0000A7D4015B28B7 AS DateTime))
INSERT [dbo].[ClassifiedCategory] ([Catid], [CategoryName], [Image], [IsActive], [EntryDate]) VALUES (N'C859840901', N'CATERING', NULL, 1, CAST(0x0000A7BF00635D13 AS DateTime))
SET IDENTITY_INSERT [dbo].[CMS_tbl] ON 

INSERT [dbo].[CMS_tbl] ([Id], [Imagefor], [Image], [Title], [Sub_Title]) VALUES (1, N'Buy', N'08122017095822090_10.jpg', N'Find your DREAM home TODAY', N'The process of buying home is A-BIG-DEAL, because we understand you. We stand by you step by step.')
INSERT [dbo].[CMS_tbl] ([Id], [Imagefor], [Image], [Title], [Sub_Title]) VALUES (2, N'Sale', N'27102017154539283_7.jpg', N'Sell your house TODAY', N'Selling your house should be a quick and easy for process. We have professional agents ready to help')
INSERT [dbo].[CMS_tbl] ([Id], [Imagefor], [Image], [Title], [Sub_Title]) VALUES (3, N'Rent', N'27102017154547226_8.jpg', N'Find your rental TODAY', N'Finding a rental should be this EASY.')
INSERT [dbo].[CMS_tbl] ([Id], [Imagefor], [Image], [Title], [Sub_Title]) VALUES (4, N'Commercial', N'27102017154555852_9.jpg', N'Find your Commercial Property Today', N'Number ONE COMMERCIAL properties FOR SALE and FOR LEASE')
SET IDENTITY_INSERT [dbo].[CMS_tbl] OFF
SET IDENTITY_INSERT [dbo].[Contact_Tbl] ON 

INSERT [dbo].[Contact_Tbl] ([CId], [ContactId], [Name], [Email], [Contact], [Subject], [Message], [Entrydate], [Status]) VALUES (12, N'C158821476', N'Test name ', N'john@goigi.net', N'98765432210', N'update', N'<p><span style="background-color: rgb(255, 255, 0);">Demo text</span></p>', CAST(0x0000A7F90161EA7A AS DateTime), 1)
INSERT [dbo].[Contact_Tbl] ([CId], [ContactId], [Name], [Email], [Contact], [Subject], [Message], [Entrydate], [Status]) VALUES (13, N'C853398288', N'Test name ', N'test@goigi.net', N'9876543210', N'test', N'<p><span style="background-color: rgb(255, 255, 0);">Demo text</span></p>', CAST(0x0000A7F90166716A AS DateTime), 1)
INSERT [dbo].[Contact_Tbl] ([CId], [ContactId], [Name], [Email], [Contact], [Subject], [Message], [Entrydate], [Status]) VALUES (14, N'C133666149', N'    aaaa', N'test@gmail.com', N'98777777777', N'aaa', N'<p>aaa</p>', CAST(0x0000A81901006703 AS DateTime), 1)
INSERT [dbo].[Contact_Tbl] ([CId], [ContactId], [Name], [Email], [Contact], [Subject], [Message], [Entrydate], [Status]) VALUES (10014, N'C729285530', N' xcxzc', N' adasdsadd', N'321312', N'         zxcczcz', N'<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; weqweqw</p>', CAST(0x0000A84400ED0F92 AS DateTime), 1)
INSERT [dbo].[Contact_Tbl] ([CId], [ContactId], [Name], [Email], [Contact], [Subject], [Message], [Entrydate], [Status]) VALUES (10015, N'C062167405', N'  Test Name', N'email@gmail.com', N'9876543210', N'Test Subject', N'<p>&nbsp;&nbsp;&nbsp;&nbsp;<br></p>', CAST(0x0000A84400F0E058 AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[Contact_Tbl] OFF
SET IDENTITY_INSERT [dbo].[ContactPage] ON 

INSERT [dbo].[ContactPage] ([Id], [Primary_Email], [Secondary_Email], [Primary_Contact], [Secondary_Contact], [Address], [City], [ZipCode], [Status]) VALUES (4, N'info@khupho.com', N'kayly@khupho.com', N'888-888-8888', N'888-888-8888', N'1450 Old Page Mill Road, Palo Alto, CA, United States', N'Palo Alto', N'94304', 1)
SET IDENTITY_INSERT [dbo].[ContactPage] OFF
SET IDENTITY_INSERT [dbo].[Content_tbl] ON 

INSERT [dbo].[Content_tbl] ([Id], [Page_Name], [Page_Title], [Page_Heading], [Section], [Page_Content]) VALUES (1, N'Home', N'Home', N'Home', N'Find New Home', N'<h1>Find your new home today or tomorrow.</h1>

<p>The real estate agents can also create a profile and upload their property listings into the website&nbsp;</p>
')
INSERT [dbo].[Content_tbl] ([Id], [Page_Name], [Page_Title], [Page_Heading], [Section], [Page_Content]) VALUES (2, N'TERMS', N'TERMS & CONDITION', N'TERMS', N'TERMS', NULL)
INSERT [dbo].[Content_tbl] ([Id], [Page_Name], [Page_Title], [Page_Heading], [Section], [Page_Content]) VALUES (3, N'POLICY', N'PRIVACY POLICY', N'TERMS', N'POLICY', NULL)
SET IDENTITY_INSERT [dbo].[Content_tbl] OFF
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E039869187', NULL, NULL, N'DATE', NULL, CAST(0x2C3D0B00 AS Date), NULL, CAST(0x07004C64EB810000 AS Time), CAST(0x070066D503840000 AS Time), 1, CAST(0x0000A7D1002BFB7F AS DateTime), N'U616637881', N'OPEN HOUSE', N'P201046313', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E060643618', NULL, NULL, N'DATE', NULL, CAST(0x283D0B00 AS Date), NULL, CAST(0x07001882BA7D0000 AS Time), CAST(0x0700E80A7E8E0000 AS Time), 1, CAST(0x0000A7C700C0A169 AS DateTime), N'U616637881', N'OPEN HOUSE', N'P103902545', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E066189265', NULL, NULL, N'DATE', NULL, CAST(0x443D0B00 AS Date), NULL, NULL, NULL, 1, CAST(0x0000A7E700A12F8A AS DateTime), N'U889546954', N'OPEN HOUSE', N'P660086996', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E070552022', NULL, N'DASFASDF', N'EVERY', NULL, NULL, NULL, NULL, NULL, 1, CAST(0x0000A7A30176D23B AS DateTime), N'U831603621', N'REMINDER', NULL, N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E223933478', NULL, NULL, N'BETWEEN', NULL, CAST(0x193D0B00 AS Date), CAST(0x1A3D0B00 AS Date), CAST(0x070050CFDF960000 AS Time), CAST(0x07002058A3A70000 AS Time), 1, CAST(0x0000A7BB006B31C4 AS DateTime), N'U831603621', N'OPEN HOUSE', N'P129699116', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E230707184', NULL, NULL, N'EVERY', 6, NULL, NULL, CAST(0x070048F9F66C0000 AS Time), CAST(0x0700E80A7E8E0000 AS Time), 1, CAST(0x0000A7F8016367A7 AS DateTime), N'U831603621', N'OPEN HOUSE', N'P062160271', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E233728166', NULL, NULL, N'DATE', NULL, CAST(0x363D0B00 AS Date), NULL, CAST(0x070068C461080000 AS Time), CAST(0x070032F3D27F0000 AS Time), 1, CAST(0x0000A7D70009C0E5 AS DateTime), N'U831603621', N'OPEN HOUSE', N'P130282523', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E271148564', NULL, N'nat test 2', N'EVERY', NULL, NULL, NULL, CAST(0x07000A527FBA0000 AS Time), CAST(0x07000A527FBA0000 AS Time), 1, CAST(0x0000A7A2016A31B4 AS DateTime), N'U974389827', N'OPEN HOUSE', NULL, N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E300462250', NULL, N'CLOSE CLOSE CLOSE', N'DATE', NULL, CAST(0x133D0B00 AS Date), NULL, NULL, NULL, 1, CAST(0x0000A7B600D435A6 AS DateTime), N'U831603621', N'REMINDER', NULL, N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E464707811', NULL, NULL, N'DATE', NULL, CAST(0x283D0B00 AS Date), NULL, CAST(0x07007CDB27710000 AS Time), CAST(0x0700B0BD58750000 AS Time), 1, CAST(0x0000A7CA00DDD404 AS DateTime), N'U831603621', N'OPEN HOUSE', N'P130282523', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E522256486', NULL, NULL, N'DATE', NULL, CAST(0x2F3D0B00 AS Date), NULL, CAST(0x070040230E430000 AS Time), CAST(0x070074053F470000 AS Time), 1, CAST(0x0000A7D20077B371 AS DateTime), N'U889546954', N'OPEN HOUSE', N'P595991847', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E529750933', NULL, N'OPEN OPEN OPEN', N'DATE', NULL, CAST(0x133D0B00 AS Date), NULL, NULL, NULL, 1, CAST(0x0000A7B600D41599 AS DateTime), N'U831603621', N'REMINDER', NULL, N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E533877633', NULL, NULL, N'DATE', NULL, CAST(0x1A3D0B00 AS Date), NULL, NULL, NULL, 1, CAST(0x0000A7BB009E4E34 AS DateTime), N'U831603621', N'OPEN HOUSE', N'P317239079', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E553242460', NULL, NULL, N'DATE', NULL, CAST(0x213D0B00 AS Date), NULL, CAST(0x070048F9F66C0000 AS Time), CAST(0x070080461C860000 AS Time), 1, CAST(0x0000A7C2007810F5 AS DateTime), N'U831603621', N'OPEN HOUSE', N'P129699116', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E696392241', NULL, NULL, N'EVERY', 0, NULL, NULL, CAST(0x0700F63AB9510000 AS Time), CAST(0x0700B893419F0000 AS Time), 1, CAST(0x0000A823012571BF AS DateTime), N'U831603621', N'OPEN HOUSE', N'P355162091', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E726289703', NULL, NULL, N'EVERY', 0, NULL, NULL, CAST(0x0700A47C7B360000 AS Time), CAST(0x070084B1109B0000 AS Time), 1, CAST(0x0000A7E8009AABDB AS DateTime), N'U572543338', N'OPEN HOUSE', N'P524693414', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E736172167', NULL, NULL, N'BETWEEN', NULL, CAST(0x4B3D0B00 AS Date), CAST(0x4B3D0B00 AS Date), CAST(0x070048F9F66C0000 AS Time), CAST(0x0700E80A7E8E0000 AS Time), 1, CAST(0x0000A7E800928FA0 AS DateTime), N'U068476417', N'OPEN HOUSE', N'P192016571', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E758104052', NULL, N'CALL CUSTOMERS', N'DATE', NULL, CAST(0x033D0B00 AS Date), NULL, CAST(0x0700D85EAC3A0000 AS Time), CAST(0x0700F2CFC43C0000 AS Time), 1, CAST(0x0000A7A3007149AD AS DateTime), N'U974389827', N'REMINDER', NULL, N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E787677343', NULL, N'Notes', N'BETWEEN', NULL, CAST(0x003D0B00 AS Date), CAST(0x023D0B00 AS Date), CAST(0x0700E49F89790000 AS Time), CAST(0x07004C64EB810000 AS Time), 1, CAST(0x0000A7A5001FA964 AS DateTime), N'U983041850', N'REMINDER', NULL, N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E821233082', NULL, NULL, N'DATE', NULL, CAST(0x443D0B00 AS Date), NULL, NULL, NULL, 1, CAST(0x0000A7E8007C8AE9 AS DateTime), N'U679844771', N'OPEN HOUSE', N'P530536721', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E853318667', NULL, N'REMINDER CALL TO CLIENTS 2', N'DATE', NULL, CAST(0x143D0B00 AS Date), NULL, CAST(0x0700D85EAC3A0000 AS Time), CAST(0x0700F2CFC43C0000 AS Time), 1, CAST(0x0000A7A30070ECE1 AS DateTime), N'U974389827', N'REMINDER', NULL, N'done')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E862549654', NULL, NULL, N'DATE', NULL, CAST(0x2F3D0B00 AS Date), NULL, CAST(0x070048F9F66C0000 AS Time), CAST(0x0700B0BD58750000 AS Time), 1, CAST(0x0000A7D200D07547 AS DateTime), N'U100955369', N'OPEN HOUSE', N'P606913025', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E943298976', NULL, NULL, N'EVERY', 6, NULL, NULL, CAST(0x070048F9F66C0000 AS Time), CAST(0x070080461C860000 AS Time), 1, CAST(0x0000A7F40050FDBC AS DateTime), N'U831603621', N'OPEN HOUSE', N'P667672818', N'active')
INSERT [dbo].[Events_Table] ([EventId], [EventTitle], [Description], [ShownType], [ShowingDay], [Start_Date], [End_Date], [Start_Time], [End_Time], [IsActive], [Entry_Date], [CreatedBy], [Event_Type], [PropertyId], [DisplayStatus]) VALUES (N'E980014623', NULL, NULL, N'DATE', NULL, CAST(0x433D0B00 AS Date), NULL, CAST(0x07004C64EB810000 AS Time), CAST(0x070080461C860000 AS Time), 1, CAST(0x0000A7E800292C33 AS DateTime), N'U616637881', N'OPEN HOUSE', N'P201046313', N'active')
SET IDENTITY_INSERT [dbo].[Favourite_Property] ON 

INSERT [dbo].[Favourite_Property] ([Id], [Profile_Id], [PropertyId], [Entrydate]) VALUES (8, N'U831603621', N'P062160271', CAST(0x0000A7FA01268C57 AS DateTime))
INSERT [dbo].[Favourite_Property] ([Id], [Profile_Id], [PropertyId], [Entrydate]) VALUES (1002, N'U831603621', N'P355162091', CAST(0x0000A82D00D9C45D AS DateTime))
SET IDENTITY_INSERT [dbo].[Favourite_Property] OFF
INSERT [dbo].[FeatureCategory] ([FeatureCatId], [FeatureCategory], [EntryDate]) VALUES (N'FC184141611', N'Indoor Amenities', CAST(0x0000A7750064D60E AS DateTime))
INSERT [dbo].[FeatureCategory] ([FeatureCatId], [FeatureCategory], [EntryDate]) VALUES (N'FC417412669', N'Basic Feature', CAST(0x0000A77E0044E379 AS DateTime))
INSERT [dbo].[FeatureCategory] ([FeatureCatId], [FeatureCategory], [EntryDate]) VALUES (N'FC593505960', N'Outdoor Amenities', CAST(0x0000A77500653508 AS DateTime))
INSERT [dbo].[FeatureCategory] ([FeatureCatId], [FeatureCategory], [EntryDate]) VALUES (N'FC697114802', N'Utilities Available', CAST(0x0000A82300AF1A5E AS DateTime))
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F054076156', N'Garden', N'CHECKBOX', N'FC593505960', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F055491247', N'APN', N'NUMBER', N'FC417412669', 1)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F184141611', N'Cable TV', N'CHECKBOX', N'FC184141611', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F268378060', N'Wifi', N'CHECKBOX', N'FC184141611', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F312616356', N'Security System', N'CHECKBOX', N'FC184141611', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F338342725', N'Garage', N'NUMBER', N'FC417412669', 1)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F349971975', N'HOA', N'NUMBER', N'FC417412669', 1)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F374882122', N'Fence', N'CHECKBOX', N'FC184141611', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F404027867', N'Test', N'NORMAL', N'FC087687815', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F417412669', N'Beds', N'NUMBER', N'FC417412669', 1)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F480985221', N'Air Conditioner', N'CHECKBOX', N'FC480985221', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F504317936', N'Internet', N'CHECKBOX', N'FC184141611', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F593505960', N'Balcony', N'CHECKBOX', N'FC593505960', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F630017472', N'Fans', N'CHECKBOX', N'FC184141611', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F640227316', N'azx', N'NUMBER', N'FC640227316', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F660635137', N'kljlkjlk', N'CHECKBOX', N'FC660635137', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F677138400', N'Baths', N'NUMBER', N'FC417412669', 1)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F937140764', N'Heater', N'CHECKBOX', N'FC480985221', NULL)
INSERT [dbo].[FeatureMaster] ([FeatureId], [FeatureName], [FeatureType], [FeatureCatId], [IsDefault]) VALUES (N'F960558418', N'Pool', N'CHECKBOX', N'FC593505960', NULL)
SET IDENTITY_INSERT [dbo].[Friends_tbl] ON 

INSERT [dbo].[Friends_tbl] ([Id], [From], [To], [Status], [EntryDate]) VALUES (20004, N'U831603621', N'U889546954', N'sent', CAST(0x0000A846013E0C81 AS DateTime))
INSERT [dbo].[Friends_tbl] ([Id], [From], [To], [Status], [EntryDate]) VALUES (20005, N'U831603621', N'U679844771', N'accepted', CAST(0x0000A846014595BA AS DateTime))
SET IDENTITY_INSERT [dbo].[Friends_tbl] OFF
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I039629872', N'Tenant', N'I039629872.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I081598253', N'Image4', N'I081598253.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I129210128', N'OverseaProperty2', N'I129210128.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I171633148', N'Image3', N'I171633148.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I208190579', N'Tenant', N'I208190579.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I213187259', N'Tenant', N'I213187259.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I315756091', N'Tenant', N'I315756091.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I385803056', N' Gryphonestate Image', N'I385803056.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I401984130', N' Gryphonestate Image', N'I401984130.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I430585441', N' Gryphonestate Image', N'I430585441.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I664690215', N'Image5', N'I664690215.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I673564003', N'Tenant', N'I673564003.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I769177582', N'OverseaProperty1', N'I769177582.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I775252986', N' Gryphonestate Image', N'I775252986.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I790665004', N'Image1', N'I790665004.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I793912232', N'Image2', N'I793912232.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I865797233', N' Gryphonestate Image', N'I865797233.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I877149846', N'OverseaProperty', N'I877149846.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I878952499', N'Image', N'I878952499.jpg')
INSERT [dbo].[Gallery] ([id], [Title], [Image]) VALUES (N'I893868161', N' Gryphonestate Image', N'I893868161.jpg')
INSERT [dbo].[Holiday_tbl] ([HolidayId], [Holiday_Name], [Holiday_On], [Holiday_Date], [Start_Date], [End_Date], [About_Holiday], [Entry_Date]) VALUES (N'H067730964', N'NEW YEAR''S EVE', N'Date', CAST(0xB53D0B00 AS Date), CAST(0x00000000 AS Date), CAST(0x00000000 AS Date), N'Quick Facts
New Year''s Eve is the last day of the year in the Gregorian calendar. Many parties to welcome the New Year are held in in the United States on New Year''s Eve.', CAST(0x0000A7F300FBFC5E AS DateTime))
INSERT [dbo].[Holiday_tbl] ([HolidayId], [Holiday_Name], [Holiday_On], [Holiday_Date], [Start_Date], [End_Date], [About_Holiday], [Entry_Date]) VALUES (N'H232541312', N'CHRISTMAS DAY', N'Date', CAST(0xAF3D0B00 AS Date), CAST(0x00000000 AS Date), CAST(0x00000000 AS Date), N'Quick Facts
Christmas Day celebrates Jesus Christ''s birth.', CAST(0x0000A7F300FBC051 AS DateTime))
INSERT [dbo].[Holiday_tbl] ([HolidayId], [Holiday_Name], [Holiday_On], [Holiday_Date], [Start_Date], [End_Date], [About_Holiday], [Entry_Date]) VALUES (N'H524267418', N'COLUMBUS DAY', N'Date', CAST(0x653D0B00 AS Date), CAST(0x00000000 AS Date), CAST(0x00000000 AS Date), N'On October 12, 1492, Italian navigator Christopher Columbus landed in the New World. Although most other nations of the Americas observe this holiday on October 12, in the United States it takes place', CAST(0x0000A7D700CB640B AS DateTime))
INSERT [dbo].[Holiday_tbl] ([HolidayId], [Holiday_Name], [Holiday_On], [Holiday_Date], [Start_Date], [End_Date], [About_Holiday], [Entry_Date]) VALUES (N'H723784037', N'THANKSGIVING DAY', N'Date', CAST(0x8F3D0B00 AS Date), CAST(0x00000000 AS Date), CAST(0x00000000 AS Date), N'Quick Facts
Thanksgiving Day in the United States is traditionally a holiday to give thanks for the food collected at the end of the harvest season.
', CAST(0x0000A7F300FA5914 AS DateTime))
INSERT [dbo].[Holiday_tbl] ([HolidayId], [Holiday_Name], [Holiday_On], [Holiday_Date], [Start_Date], [End_Date], [About_Holiday], [Entry_Date]) VALUES (N'H794245037', N'demo holiday', N'Between', CAST(0x00000000 AS Date), CAST(0x873D0B00 AS Date), CAST(0x8E3D0B00 AS Date), N'demo', CAST(0x0000A82B00ECE26F AS DateTime))
INSERT [dbo].[Holiday_tbl] ([HolidayId], [Holiday_Name], [Holiday_On], [Holiday_Date], [Start_Date], [End_Date], [About_Holiday], [Entry_Date]) VALUES (N'H801311393', N'CHRISTMAS EVE', N'Date', CAST(0xAE3D0B00 AS Date), CAST(0x00000000 AS Date), CAST(0x00000000 AS Date), N'Quick Facts
Christmas Eve in the United States is on December 24 each year.', CAST(0x0000A7F300FB845D AS DateTime))
INSERT [dbo].[Holiday_tbl] ([HolidayId], [Holiday_Name], [Holiday_On], [Holiday_Date], [Start_Date], [End_Date], [About_Holiday], [Entry_Date]) VALUES (N'H808827451', N'Demo', N'Between', CAST(0x00000000 AS Date), CAST(0x873D0B00 AS Date), CAST(0x893D0B00 AS Date), N'demo', CAST(0x0000A82B00F89839 AS DateTime))
SET IDENTITY_INSERT [dbo].[Login_Table] ON 

INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (1, 2, N'U831603621', N'john@gmail.com', N'John', N'Doe', N'123456', 1, 1, CAST(0x0000A85100C79669 AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (2, 2, N'U679844771', N'matt2017@gmail.com', N'Matt', N'Henry', N'123456', 1, 1, CAST(0x0000A850012DB12B AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (3, 1, N'U064962753', N'luke@gmail.com', N'Luke', N'harper', N'123456', 0, 1, NULL, NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (4, 2, N'U616637881', N'joe@goigi.net', N'Joe', N'Campbell', N'123456', 0, 1, CAST(0x0000A81A00C78666 AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (5, 3, N'U097531010', N'lynda@gmail.com', N'Lynda', N'Rossy', N'123456', 1, 1, CAST(0x0000A81A00FA5B0E AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (6, 1, N'U528509529', N'test@goigi.net', N'Selma', N'Hendricks', N'123456', 0, 1, CAST(0x0000A81A009AFBD4 AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (7, 1, N'U974389827', N'jc@gmail.com', N'johnny', N'cash', N'123456', 0, 1, CAST(0x0000A7E8007C57BC AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (8, 1, N'U501082657', N'bobby@gmail.com', N'Bobby', N'bobby', N'123456', 0, 1, NULL, NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (9, 1, N'U840729486', N'mark@gmail.com', N'Mark', N'Wayne', N'123456', 0, 1, NULL, NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (10, 1, N'U014877963', N'jack2017@goigi.net', N'Jack', N'Sparrow', N'123456', 0, 1, NULL, NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (12, 1, N'U052555274', N'demobuyer@gmail.com', N'Demo', N'Buyer', N'123456', 0, 1, NULL, NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (13, 2, N'U889546954', N'george@gmail.com', N'GEORGE ', N'WASHINGTON', N'123456', 0, 1, CAST(0x0000A84700969489 AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (14, 2, N'U068476417', N'william@gmail.com', N'WILLIAM', N'NGUYEN', N'123456', 0, 1, CAST(0x0000A7EC0186CADF AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (15, 1, N'U100955369', N'william1@gmail.com', N'WILLIAM', N'NGUYEN', N'123456', 1, 1, CAST(0x0000A81F012541E0 AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (16, 1, N'U333611123', N'web010220171@goigi.asia', N'John', N'Doe', N'123456', 0, 1, CAST(0x0000A7DA00775432 AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (19, 2, N'U239950756', N'apx510@gmail.com', N'Nathan', N'Nguyen', NULL, 0, 1, NULL, N'100068823830666799384')
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (20, 1, N'U842876075', N'kayly@khupho.com', N'HAMILTON', N'WYNN', N'123456', 0, 0, NULL, NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (21, 2, N'U572543338', N'apx916@gmail.com', N'HAMILTON', N'WYNN', N'123456', 0, 1, CAST(0x0000A7ED00F23C5F AS DateTime), NULL)
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (23, 1, N'U317986945', N'wearegoigi@gmail.com', N'Weare', N'Goigi', NULL, 1, 1, NULL, N'656428454745419')
INSERT [dbo].[Login_Table] ([LoginId], [Uid], [UserId], [EmailId], [FirstName], [LastName], [Password], [Status], [Email_verified], [Last_visited], [googleId]) VALUES (24, 1, N'U701938473', N'mazumdar.19081994@gmail.com', N'Sourav', N'Majumdar', NULL, 1, 1, NULL, N'1559531027492844')
SET IDENTITY_INSERT [dbo].[Login_Table] OFF
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1', N'U831603621', N'U097531010', N'Hi', 1, CAST(0x0000A81A007347E8 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'10', N'U831603621', N'U097531010', N'Hello', 1, CAST(0x0000A81A0078A45D AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1002', N'U100955369', N'U831603621', N'Hi', 1, CAST(0x0000A81C00B90CD8 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1003', N'U831603621', N'U100955369', N'hello buddy', 1, CAST(0x0000A81C00C3976B AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1004', N'U100955369', N'U831603621', N'Hi...', 1, CAST(0x0000A81C00C39F0D AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1005', N'U100955369', N'U831603621', N'what r doing', 1, CAST(0x0000A81C00C3A72A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1006', N'U831603621', N'U100955369', N'I m doing good', 1, CAST(0x0000A81C00C3B1D6 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1007', N'U831603621', N'U100955369', N'hello', 1, CAST(0x0000A81C00D27E1E AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1008', N'U831603621', N'U100955369', N'How r u', 1, CAST(0x0000A81C00D2854B AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1009', N'U831603621', N'U679844771', N'How r u', 1, CAST(0x0000A81C00D28D16 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1010', N'U831603621', N'U679844771', N'I am fine .tell me urs', 1, CAST(0x0000A81C00D2A7C8 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1011', N'U100955369', N'U831603621', N'goo', 1, CAST(0x0000A81C00D2D654 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1012', N'U100955369', N'U831603621', N'good', 1, CAST(0x0000A81C00D2DD2A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1013', N'U831603621', N'U100955369', N'ok', 1, CAST(0x0000A81C00D2E08B AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1014', N'U831603621', N'U100955369', N'asASasASa', 1, CAST(0x0000A81E0060513E AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'1015', N'U831603621', N'U679844771', N'jjj', 1, CAST(0x0000A81E0064C896 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'11', N'U097531010', N'U831603621', N'How are u', 1, CAST(0x0000A81A0078AB77 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'12', N'U831603621', N'U097531010', N'Im fine', 1, CAST(0x0000A81A0078B5A5 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'13', N'U097531010', N'U831603621', N'(:', 1, CAST(0x0000A81A0078CF7A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'14', N'U097531010', N'U831603621', N':)', 1, CAST(0x0000A81A0078D43D AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'15', N'U831603621', N'U097531010', N'what do you do', 1, CAST(0x0000A81A0078E322 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'16', N'U097531010', N'U831603621', N'nothing', 1, CAST(0x0000A81A0078E8DD AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'17', N'U097531010', N'U831603621', N'hhhhhhhhhhhhh', 1, CAST(0x0000A81A0079976C AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'18', N'U097531010', N'U831603621', N'how are you...', 1, CAST(0x0000A81A0079B859 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'19', N'U831603621', N'U097531010', N'I am fine', 1, CAST(0x0000A81A0079C486 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2', N'U097531010', N'U831603621', N'Hiiiii', 1, CAST(0x0000A81A0073546A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'20', N'U831603621', N'U097531010', N'Hi]', 1, CAST(0x0000A81A007D2DFD AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2014', N'U831603621', N'U100955369', N'asdasdas', 1, CAST(0x0000A81E00798D04 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2015', N'U831603621', N'U679844771', N'asdasdsada', 1, CAST(0x0000A81E00799046 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2016', N'U831603621', N'U679844771', N'asdasdasdasdasd', 1, CAST(0x0000A81E009F5A97 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2017', N'U831603621', N'U100955369', N'asdasdas', 1, CAST(0x0000A81F008EC426 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2018', N'U831603621', N'U679844771', N'asdasdasdsa', 1, CAST(0x0000A81F008EC757 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2019', N'U831603621', N'U679844771', N'ASasASa', 1, CAST(0x0000A81F008F2C74 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2020', N'U831603621', N'U679844771', N'dadasdasd', 1, CAST(0x0000A81F008FB21C AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2021', N'U831603621', N'U100955369', N'asdasdasd', 1, CAST(0x0000A81F008FB528 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2022', N'U831603621', N'U679844771', N'asdasdasd??????????????????', 1, CAST(0x0000A81F00B7C0BF AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2023', N'U831603621', N'U679844771', N'????????????????????', 1, CAST(0x0000A81F00B94981 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2024', N'U831603621', N'U100955369', N'??????????', 1, CAST(0x0000A81F00B9511C AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2025', N'U831603621', N'U100955369', N'gjhagsdjhgasd', 1, CAST(0x0000A81F00BD8CE6 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2026', N'U831603621', N'U100955369', N'gjhagsdjhgasd<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f606.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f617.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f605.png">', 1, CAST(0x0000A81F00BD9673 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2027', N'U831603621', N'U100955369', N'<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png">', 1, CAST(0x0000A81F00BE9F61 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2028', N'U831603621', N'U679844771', N'<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png">', 1, CAST(0x0000A81F00BEF2C6 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2029', N'U831603621', N'U679844771', N'kjashkdha<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f603.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f606.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60f.png">', 1, CAST(0x0000A81F00BF0352 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2030', N'U831603621', N'U100955369', N'nahi to<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png">', 1, CAST(0x0000A81F00BF111D AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2031', N'U831603621', N'U100955369', N'<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60c.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f603.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f606.png">', 1, CAST(0x0000A81F00C03E67 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2032', N'U831603621', N'U100955369', N'<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png">', 1, CAST(0x0000A81F00C045FD AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2033', N'U831603621', N'U100955369', N'<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png">', 1, CAST(0x0000A81F00C05844 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2034', N'U831603621', N'U100955369', N'Hi<img alt="?" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/2764.png"><img alt="???" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/270b-1f3fb.png">', 1, CAST(0x0000A81F00C0B61E AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2035', N'U831603621', N'U100955369', N'<img alt="????" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f443-1f3fb.png"><img alt="????" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f443-1f3fb.png">', 1, CAST(0x0000A81F00C189D4 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2036', N'U831603621', N'U100955369', N'asdasdas<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f606.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f606.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f606.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f606.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f606.png">', 1, CAST(0x0000A81F00C21540 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2037', N'U831603621', N'U100955369', N'<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f911.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f911.png">', 1, CAST(0x0000A81F00C275E6 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2038', N'U831603621', N'U100955369', N':)', 1, CAST(0x0000A81F00C27BFB AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2039', N'U100955369', N'U831603621', N'-:)', 1, CAST(0x0000A81F00C2CEC0 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2040', N'U831603621', N'U100955369', N'Hello', 1, CAST(0x0000A81F00C2E5A9 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2041', N'U100955369', N'U831603621', N'Hi', 1, CAST(0x0000A81F00C2EB04 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2042', N'U831603621', N'U100955369', N'Hello', 1, CAST(0x0000A81F00C32418 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2043', N'U100955369', N'U831603621', N'How r u', 1, CAST(0x0000A81F00C32D36 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2044', N'U831603621', N'U100955369', N'How r u', 1, CAST(0x0000A81F00C33B09 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2045', N'U831603621', N'U100955369', N'<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png">', 1, CAST(0x0000A81F00C43E0C AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2046', N'U100955369', N'U831603621', N'fINE', 1, CAST(0x0000A81F00C7BD24 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2047', N'U831603621', N'U100955369', N'oooioiud', 1, CAST(0x0000A81F00C8A660 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2048', N'U100955369', N'U831603621', N'hiiii', 1, CAST(0x0000A81F00C8ACF7 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2049', N'U831603621', N'U679844771', N'Hello', 1, CAST(0x0000A81F00C8B68A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2050', N'U831603621', N'U100955369', N'<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f604.png">', 1, CAST(0x0000A81F00C8C353 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2051', N'U831603621', N'U100955369', N'Hello<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f62f.png">', 1, CAST(0x0000A81F00C8E85F AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2052', N'U831603621', N'U100955369', N'Hello<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f644.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f644.png">', 1, CAST(0x0000A81F00C91A52 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2053', N'U831603621', N'U100955369', N'Hhkhewkrhwe<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png">', 1, CAST(0x0000A81F00C97791 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2054', N'U831603621', N'U100955369', N'Hhkhewkrhwe<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f61f.png">', 1, CAST(0x0000A81F00C99899 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2055', N'U100955369', N'U831603621', N'asdasdas', 1, CAST(0x0000A81F00CA37ED AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2056', N'U831603621', N'U679844771', N'asdasdasdasdasddasdasdasdasdasdadaasasdd', 1, CAST(0x0000A81F00CA68D5 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2057', N'U100955369', N'U831603621', N'dasdasasdasdasasasddasdasasddas', 1, CAST(0x0000A81F00CA730A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2058', N'U831603621', N'U679844771', N'asdasdasdasd', 1, CAST(0x0000A81F00CA7832 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2059', N'U831603621', N'U679844771', N'asdsa', 1, CAST(0x0000A81F00CAB755 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2060', N'U831603621', N'U100955369', N'GGGGG', 1, CAST(0x0000A81F00CAD203 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2061', N'U831603621', N'U100955369', N'asdasdsdfsadsa', 1, CAST(0x0000A81F00CAFB24 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2062', N'U831603621', N'U100955369', N'ASDASDASD', 1, CAST(0x0000A81F00CB0166 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2063', N'U100955369', N'U831603621', N'<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png">', 1, CAST(0x0000A81F00CB0C63 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2064', N'U831603621', N'U100955369', N'SADFASDAS', 1, CAST(0x0000A81F00CB3947 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2065', N'U831603621', N'U100955369', N'hELLO', 1, CAST(0x0000A81F00CB4605 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2066', N'U831603621', N'U100955369', N'Hello', 1, CAST(0x0000A81F00CF60F6 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2067', N'U831603621', N'U100955369', N'kokok', 1, CAST(0x0000A81F00CF74BA AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2068', N'U831603621', N'U100955369', N'okjojo', 1, CAST(0x0000A81F00CFF132 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2069', N'U831603621', N'U100955369', N'Hello', 1, CAST(0x0000A81F00D046B5 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2070', N'U831603621', N'U100955369', N'hdjkashdkha', 1, CAST(0x0000A81F00D05180 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2071', N'U831603621', N'U100955369', N'jjoj', 1, CAST(0x0000A81F00D0B139 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2072', N'U831603621', N'U100955369', N'111', 1, CAST(0x0000A81F00D0C33F AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2073', N'U831603621', N'U100955369', N'sdasdasd', 0, CAST(0x0000A8420050961C AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2074', N'U831603621', N'U679844771', N'Hi', 1, CAST(0x0000A84200523FE9 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2075', N'U831603621', N'U679844771', N'How r u', 1, CAST(0x0000A84200524718 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2076', N'U679844771', N'U831603621', N'I am fine', 1, CAST(0x0000A842005509E4 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2077', N'U831603621', N'U679844771', N'Nice to hear u', 1, CAST(0x0000A84200552152 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2078', N'U679844771', N'U831603621', N'Yap', 1, CAST(0x0000A842005528ED AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2079', N'U831603621', N'U100955369', N'Hellow', 0, CAST(0x0000A84200555222 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2080', N'U831603621', N'U679844771', N'Hello', 1, CAST(0x0000A84200555DC2 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2081', N'U679844771', N'U831603621', N'yap', 1, CAST(0x0000A84200556380 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2082', N'U831603621', N'U679844771', N'<img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f603.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f603.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f603.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f603.png"><img alt="??" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f603.png">', 1, CAST(0x0000A84600E25AF6 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2083', N'U679844771', N'U679844771', N'Hi', 0, CAST(0x0000A84E00A1D8DB AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2084', N'U679844771', N'U679844771', N'How r u', 0, CAST(0x0000A84E00A1DDE2 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2085', N'U679844771', N'U679844771', N'Hi', 0, CAST(0x0000A84E00A20465 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2086', N'U831603621', N'U679844771', N'j', 1, CAST(0x0000A84E00CE9B44 AS DateTime), N'Send', N'NA', 0)
GO
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2087', N'U831603621', N'U679844771', N'asdasdas', 1, CAST(0x0000A84E00D291BB AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2088', N'U831603621', N'U679844771', N'Hello dear', 1, CAST(0x0000A84E00D2974A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2089', N'U831603621', N'U679844771', N'jjjj', 1, CAST(0x0000A84E00D33A41 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2090', N'U831603621', N'U679844771', N'adasdasd', 1, CAST(0x0000A84E00D3443E AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2091', N'U831603621', N'U679844771', N'jjj', 1, CAST(0x0000A84E00D92EAA AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2092', N'U831603621', N'U679844771', N'hello', 1, CAST(0x0000A84E00D93AB7 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2093', N'U831603621', N'U679844771', N'asdasdasd', 1, CAST(0x0000A84E00D9B469 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2094', N'U831603621', N'U679844771', N'asdasdasdassdasdasdasdads', 1, CAST(0x0000A84E00D9BD7F AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2095', N'U831603621', N'U679844771', N'Hellow dear', 1, CAST(0x0000A84E00D9C388 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2096', N'U831603621', N'U679844771', N'how r u', 1, CAST(0x0000A84E00D9CAE1 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2097', N'U831603621', N'U679844771', N'dasdasdas', 1, CAST(0x0000A84E00DD549B AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2098', N'U831603621', N'U679844771', N'asdasdasdasdasdasdasd', 1, CAST(0x0000A84E00DD5A61 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2099', N'U831603621', N'U679844771', N'fsdfsdfsdfsdfsdfsdfsdfsdf', 1, CAST(0x0000A84E00DDC4CA AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'21', N'U831603621', N'U097531010', N']sdfsdf', 1, CAST(0x0000A81A007D32EC AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2100', N'U831603621', N'U679844771', N'sdfsdfsdfsd', 1, CAST(0x0000A84E00DDC8F4 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2101', N'U831603621', N'U679844771', N'hi dear', 1, CAST(0x0000A84F00640329 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2102', N'U831603621', N'U679844771', N'Hi bro', 1, CAST(0x0000A84F00647E4D AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2103', N'U831603621', N'U679844771', N'How r u', 1, CAST(0x0000A84F00648E3C AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2104', N'U831603621', N'U679844771', N'Fine', 1, CAST(0x0000A84F006497E8 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2105', N'U831603621', N'U679844771', N'Hi', 1, CAST(0x0000A84F0069D6FD AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2106', N'U831603621', N'U679844771', N'Hi', 1, CAST(0x0000A84F00BA6804 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2107', N'U831603621', N'U679844771', N'Hell', 1, CAST(0x0000A84F00D57089 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2108', N'U831603621', N'U679844771', N'Hi', 1, CAST(0x0000A84F00D5ECFE AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2109', N'U831603621', N'U679844771', N'how r u', 1, CAST(0x0000A84F00D63A2B AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2110', N'U831603621', N'U679844771', N'how r u dear', 1, CAST(0x0000A84F00D6A2CE AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2111', N'U831603621', N'U679844771', N'i am fine', 1, CAST(0x0000A84F00D6AB23 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2112', N'U831603621', N'U679844771', N'ok', 1, CAST(0x0000A84F00D6DF97 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2113', N'U831603621', N'U679844771', N'sdfsdfsdf', 1, CAST(0x0000A84F00D83327 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2114', N'U831603621', N'U679844771', N'vcvcxvcxvcx', 1, CAST(0x0000A84F00D9546D AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2115', N'U831603621', N'U679844771', N'fdbgfdgfdgfd', 1, CAST(0x0000A84F00D95633 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2116', N'U831603621', N'U679844771', N'Hello every one', 1, CAST(0x0000A850004BAF6F AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2117', N'U831603621', N'U679844771', N'Yeah! Hi', 1, CAST(0x0000A850004BBF1A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2118', N'U831603621', N'U679844771', N'How is it going', 1, CAST(0x0000A850004BCAD2 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2119', N'U831603621', N'U679844771', N'Google', 1, CAST(0x0000A850004C09D6 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2120', N'U831603621', N'U679844771', N'Hello dear', 1, CAST(0x0000A850004E4505 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2121', N'U679844771', N'U831603621', N'Yeah hi', 1, CAST(0x0000A850004E57DD AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2122', N'U679844771', N'U831603621', N'How r u', 1, CAST(0x0000A850004E5F7F AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2123', N'U679844771', N'U831603621', N'<img alt="😎" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="😎" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="😎" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png"><img alt="😎" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60e.png">', 1, CAST(0x0000A850004EB11A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2124', N'U831603621', N'U679844771', N'wow', 1, CAST(0x0000A850004F22EA AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2125', N'U679844771', N'U831603621', N'wt', 1, CAST(0x0000A850004F2CCB AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2126', N'U831603621', N'U679844771', N'Hi', 1, CAST(0x0000A850005207FA AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2127', N'U679844771', N'U831603621', N'Hello', 1, CAST(0x0000A8500052126E AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2128', N'U831603621', N'U679844771', N'How r u', 1, CAST(0x0000A850005220D3 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2129', N'U831603621', N'U679844771', N'I am fine', 1, CAST(0x0000A8500052331A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2130', N'U831603621', N'U679844771', N'Ok', 1, CAST(0x0000A850005240B9 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2131', N'U679844771', N'U831603621', N'Thats great things', 1, CAST(0x0000A850005253BB AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2132', N'U831603621', N'U679844771', N'Hii', 1, CAST(0x0000A85000537144 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2133', N'U679844771', N'U831603621', N'Hello friends', 1, CAST(0x0000A8500053E0E6 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2134', N'U831603621', N'U679844771', N'yeah hi', 1, CAST(0x0000A8500053E99A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2135', N'U831603621', N'U679844771', N'How r u', 1, CAST(0x0000A850005402AA AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2136', N'U679844771', N'U831603621', N'fine', 1, CAST(0x0000A85000540EA3 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2137', N'U831603621', N'U679844771', N'ddfdsf f sddsfds fdsf dsf sd fdsfdsfd fd fds fsdfdsf', 1, CAST(0x0000A85000594A87 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2138', N'U679844771', N'U831603621', N'hi', 1, CAST(0x0000A850005B71F9 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2139', N'U679844771', N'U831603621', N'hello', 1, CAST(0x0000A850005C5532 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2140', N'U679844771', N'U831603621', N'hi bro', 1, CAST(0x0000A850005C6A90 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2141', N'U831603621', N'U679844771', N'dfgfgfgfgf', 1, CAST(0x0000A85000714717 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2142', N'U831603621', N'U679844771', N'<img alt="😍" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png">', 1, CAST(0x0000A850008327C2 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2143', N'U831603621', N'U679844771', N'He', 1, CAST(0x0000A8500094FF33 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2144', N'U831603621', N'U679844771', N'Hi', 1, CAST(0x0000A8500095E468 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2145', N'U679844771', N'U831603621', N'Hello....', 1, CAST(0x0000A8500096031D AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2146', N'U679844771', N'U831603621', N'where have you been', 1, CAST(0x0000A85000960ABF AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2147', N'U679844771', N'U831603621', N'<img alt="🙂" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f642.png"><img alt="🙂" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f642.png">', 1, CAST(0x0000A85000961465 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2148', N'U831603621', N'U679844771', N'just in kolkata', 1, CAST(0x0000A85000963375 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2149', N'U679844771', N'U831603621', N'Ok', 1, CAST(0x0000A8500096444E AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2150', N'U831603621', N'U679844771', N'what r u doing', 1, CAST(0x0000A850009664CB AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2151', N'U679844771', N'U831603621', N'Nothing', 1, CAST(0x0000A85000967971 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2152', N'U679844771', N'U831603621', N'ok', 1, CAST(0x0000A8500096BA78 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2153', N'U679844771', N'U831603621', N'what r u doing', 1, CAST(0x0000A8500096C4C5 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2154', N'U679844771', N'U831603621', N'nothing special', 1, CAST(0x0000A8500096D605 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2155', N'U679844771', N'U831603621', N'hello', 1, CAST(0x0000A85000976416 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2156', N'U679844771', N'U831603621', N'hi', 1, CAST(0x0000A85000976997 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2157', N'U831603621', N'U679844771', N'fine', 1, CAST(0x0000A85000976E63 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2158', N'U679844771', N'U831603621', N'yes', 1, CAST(0x0000A850009774C5 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2159', N'U831603621', N'U679844771', N'hooo', 1, CAST(0x0000A85000977A1B AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2160', N'U679844771', N'U831603621', N'dsaasdas', 1, CAST(0x0000A85000977E3C AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2161', N'U679844771', N'U831603621', N'dsfsdfsdfsdf', 1, CAST(0x0000A850009795D9 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2162', N'U831603621', N'U679844771', N'sdfsdfsdf sdfsdsdf', 1, CAST(0x0000A8500097A91C AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2163', N'U831603621', N'U679844771', N'wowww wwww', 1, CAST(0x0000A8500097AFE9 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2164', N'U679844771', N'U831603621', N'hello there', 1, CAST(0x0000A85000986179 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2165', N'U831603621', N'U679844771', N'ooooo', 1, CAST(0x0000A85000986957 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2166', N'U679844771', N'U831603621', N'hhhh', 1, CAST(0x0000A85000986DBB AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2167', N'U831603621', N'U679844771', N'hhhh', 1, CAST(0x0000A85000987225 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2168', N'U679844771', N'U831603621', N'asdasdasd', 1, CAST(0x0000A850009875C0 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2169', N'U679844771', N'U831603621', N'<img alt="😁" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f601.png"><img alt="😁" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f601.png"><img alt="😁" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f601.png"><img alt="😁" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f601.png">', 1, CAST(0x0000A850009CC369 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2170', N'U679844771', N'U831603621', N'hi', 1, CAST(0x0000A850009CD595 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2171', N'U679844771', N'U831603621', N'<img alt="☺" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/263a.png"><img alt="☺" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/263a.png"><img alt="☺" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/263a.png"><img alt="☺" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/263a.png">', 1, CAST(0x0000A850009DA8AC AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2172', N'U679844771', N'U831603621', N'<img alt="😍" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="😍" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png">', 1, CAST(0x0000A850009DB7EF AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2173', N'U679844771', N'U831603621', N'<img alt="😍" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="😍" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="😍" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f60d.png"><img alt="😘" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f618.png"><img alt="😘" class="emojioneemoji" src="https://cdnjs.cloudflare.com/ajax/libs/emojione/2.2.7/assets/png/1f618.png">', 1, CAST(0x0000A850009E3BA3 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2174', N'U679844771', N'U831603621', N'Hello', 1, CAST(0x0000A850009E59E6 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2175', N'U831603621', N'U679844771', N'hiiiii', 1, CAST(0x0000A85000A3AE76 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'2176', N'U679844771', N'U831603621', N'hello', 1, CAST(0x0000A85000A4402A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'22', N'U097531010', N'U831603621', N'Hi', 1, CAST(0x0000A81A009073A7 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'23', N'U097531010', N'U831603621', N'Hello', 1, CAST(0x0000A81A00907CBE AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'24', N'U831603621', N'U097531010', N'Yes Hi', 1, CAST(0x0000A81A0090837A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'25', N'U097531010', N'U831603621', N'Hello linda', 1, CAST(0x0000A81A0090D417 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'26', N'U831603621', N'U097531010', N'Yah how r u', 1, CAST(0x0000A81A0090E1C1 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'27', N'U097531010', N'U831603621', N'what r u doing', 1, CAST(0x0000A81A00910853 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'28', N'U097531010', N'U831603621', N'I am doing well', 1, CAST(0x0000A81A00912388 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'29', N'U831603621', N'U097531010', N'me too', 1, CAST(0x0000A81A00912CF2 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'3', N'U831603621', N'U097531010', N'How r u', 1, CAST(0x0000A81A007360E4 AS DateTime), N'Send', N'NA', 0)
GO
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'30', N'U831603621', N'U097531010', N'what abouth the party', 1, CAST(0x0000A81A00913EA5 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'31', N'U097531010', N'U831603621', N'Yeah its good', 1, CAST(0x0000A81A00914E62 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'32', N'U097531010', N'U831603621', N'How r u', 1, CAST(0x0000A81A009167AA AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'33', N'U097531010', N'U831603621', N'hi', 1, CAST(0x0000A81A009B293C AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'34', N'U679844771', N'U831603621', N'hi', 1, CAST(0x0000A81A009DD2C6 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'35', N'U679844771', N'U831603621', N'How r you', 1, CAST(0x0000A81A009DED71 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'36', N'U831603621', N'U679844771', N'Fine now', 1, CAST(0x0000A81A009DF855 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'37', N'U679844771', N'U831603621', N'ok..', 1, CAST(0x0000A81A009DFF44 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'38', N'U831603621', N'U679844771', N'uuuu', 1, CAST(0x0000A81A009E0964 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'39', N'U831603621', N'U679844771', N'bdm', 1, CAST(0x0000A81A009E51E3 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'4', N'U097531010', N'U831603621', N'hhhh', 1, CAST(0x0000A81A0073870A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'40', N'U831603621', N'U679844771', N'Hello', 1, CAST(0x0000A81A009F7CAB AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'5', N'U097531010', N'U831603621', N'hhh', 1, CAST(0x0000A81A00739C25 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'6', N'U097531010', N'U831603621', N'hello', 1, CAST(0x0000A81A0073A3C4 AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'7', N'U831603621', N'U097531010', N'Heiiii', 1, CAST(0x0000A81A0073B18F AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'8', N'U831603621', N'U097531010', N'Hi linda', 1, CAST(0x0000A81A00762B0A AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Message] ([Msg_id], [msg_from_user_id], [Msg_To_User_Id], [Message], [Is_Read], [Msg_Date], [Msg_Status], [Deleted_By], [IsPublic]) VALUES (N'9', N'U097531010', N'U831603621', N'Hi linda', 1, CAST(0x0000A81A00788EDF AS DateTime), N'Send', N'NA', 0)
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'01dc4ad9-bc44-2aae-a6b4-18339fb4a861', N'MATT HENRY PROFILE NOTES', 1, CAST(0x0000A7C8007E5503 AS DateTime), N'U679844771', NULL, N'absolute', N'428px', N'364px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'10c1e071-b8e3-5fa7-66c6-215d978a4235', N'JOE CAMPBELL&nbsp;<div><br></div><div>NOTES</div>', 1, CAST(0x0000A7C700BCB2BB AS DateTime), N'U616637881', NULL, N'absolute', N'1120px', N'436px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'19b2d142-7522-6657-f01c-f57290ff64bd', N'HAMILTON # 1 PRIVATE', 0, CAST(0x0000A7E800995D3B AS DateTime), N'U572543338', N'P524693414', N'absolute', N'10px', N'239px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'1d8fae97-3ea8-9d88-8cb3-3f8c01175753', N'VIETNAM FINEST', 1, CAST(0x0000A7D300BF29CA AS DateTime), N'U100955369', N'P135983100', N'absolute', N'10px', N'10px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'2124adf3-7412-0a21-02ae-cd4a313129bf', N'JOHNNY CASH MATT HENRY LISTING PUBLIC&nbsp;<div><br></div><div>NOT SUPPOSE TO DISPLAY</div>', 1, CAST(0x0000A7DA009BA4AE AS DateTime), N'U974389827', N'P530536721', N'absolute', N'445px', N'572px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'2aedbf6f-745c-8a77-a10c-035a6ea9468f', N'JOE CAMPBEL PROPERTY&nbsp;<div><br></div><div>NOTES</div>', 1, CAST(0x0000A7C700BDCB83 AS DateTime), N'U616637881', N'P103902545', N'absolute', N'894px', N'750px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'39e1ad78-b261-e0d5-8fea-5623b73f1339', N'HAMILTON PRIVATE NOTE', 0, CAST(0x0000A7E8009A873A AS DateTime), N'U572543338', NULL, N'absolute', N'10px', N'10px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'49ebef78-8c63-887c-257a-f2803acb2372', N'LOG IN AS MATT HENRY BUT PUTTING NOTES ON JOE CAMPBELL PULIC?', 1, CAST(0x0000A7C800809CC5 AS DateTime), N'U679844771', N'P103902545', N'absolute', N'461px', N'580px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'4ca372e4-b37e-69e4-8033-611fd58f655d', N'This test public note<div><br></div>', 1, CAST(0x0000A7D100010376 AS DateTime), N'U889546954', NULL, N'fixed', N'1093px', N'192')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'69d817d2-b151-f9dc-ffa1-8ac10209c3ad', N'1306 BAY ST PUBLIC NOTE', 1, CAST(0x0000A7DA00CB915D AS DateTime), N'U100955369', N'P493110717', N'absolute', N'10px', N'310px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'7266c6b5-191c-bc20-c8aa-2030c34c389b', N'1515 sw 5th avenue', 1, CAST(0x0000A7D60170342D AS DateTime), N'U831603621', N'P130282523', N'absolute', N'747px', N'649px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'753dc4ad-1578-c703-3d52-61c213a8d5ef', N'JOE CAMPBELL PRIVATE NOTE', 0, CAST(0x0000A7C700BFCB08 AS DateTime), N'U616637881', N'P103902545', N'absolute', N'915px', N'343px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'7a294156-9b97-62f0-3e60-2fb1ae650d90', N'LAND FOR SALE&nbsp;<div><br></div><div>WILLIAM NGUYEN</div>', 1, CAST(0x0000A7D301673820 AS DateTime), N'U100955369', N'P286353460', N'absolute', N'431px', N'665px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'7b303b03-edb4-9c64-f9a7-ef9f4d3093aa', N'HAMILTON LISTING #1', 1, CAST(0x0000A7E8009945B3 AS DateTime), N'U572543338', N'P524693414', N'absolute', N'790px', N'548px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'8d24afd8-7cdf-a2ff-f0b8-959082909f79', N'OPEN HOUSE THIS WEEKEND 09/09-09/10', 1, CAST(0x0000A7E80092ADA9 AS DateTime), N'U068476417', N'P192016571', N'absolute', N'10px', N'59px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'8f173551-77ba-078a-1a72-db6710d03e03', N'MATT HENRY LISTING PUBLIC NOTES', 1, CAST(0x0000A7C8007DBBAE AS DateTime), N'U679844771', N'P530536721', N'absolute', N'750px', N'518px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'ae83ef5c-aff9-8a35-a6a4-97bb7b7d2f16', N'JOE CAMPBELL PRIVATE NOTE<div>IN CALENDAR</div>', 0, CAST(0x0000A7C700C059EE AS DateTime), N'U616637881', NULL, N'absolute', N'1127px', N'655px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'b8b522bf-8398-a335-015e-5344d4519523', N'call commercial', 0, CAST(0x0000A7B700908C40 AS DateTime), N'U831603621', N'P734344605', N'absolute', N'1109px', N'554px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'bcc6f415-d151-99a2-c342-1ea482bc5f5a', N'commercial', 1, CAST(0x0000A7B60164BA6A AS DateTime), N'U831603621', N'P734344605', N'absolute', N'914px', N'554px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'c94ff50b-a4cf-cdd1-e15e-e0df6eb64579', N'MATT HENRY PRIVATE NOTES', 0, CAST(0x0000A7C8007E6D74 AS DateTime), N'U679844771', NULL, N'absolute', N'618px', N'365px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'c9f3aa49-aabf-a53c-41ee-207a7b7541ab', N'GEORGE 1ST PROPERTY PRIVATE NOTE', 0, CAST(0x0000A7CC008E78D7 AS DateTime), N'U889546954', N'P660086996', N'absolute', N'10px', N'10px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'cd18e648-1226-b520-9809-2f5f45ec051c', N'HAMILTON PUBLIC NOTE', 1, CAST(0x0000A7E8009A73A6 AS DateTime), N'U572543338', NULL, N'absolute', N'190px', N'50px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'ceb1f527-487d-63fe-dde6-d492e5684d02', N'WILL I AM<div>THE GURU OF REAL ESTATES</div>', 1, CAST(0x0000A7E8009372C5 AS DateTime), N'U068476417', NULL, N'absolute', N'10px', N'10px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'd10bc19c-3db7-92ee-1b57-f2fe12d3b706', N'WILLIAM WAREHOUSE<div><br></div>', 1, CAST(0x0000A7D40008E87C AS DateTime), N'U100955369', N'P461594023', N'absolute', N'10px', N'10px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'd20308b2-bef3-3557-ab03-626897ec5bae', N'BIG PARTY THIS WEEKEND', 1, CAST(0x0000A7BB0074D77C AS DateTime), N'U831603621', NULL, N'absolute', N'275px', N'31px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'd72a742e-c7b6-f8a2-7a87-3518b121d9e2', N'JOHN PUBLIC NOTE', 1, CAST(0x0000A7F40050C187 AS DateTime), N'U831603621', NULL, N'absolute', N'452px', N'27px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'e32612a4-8c3f-fa72-5014-f0007c76bb09', N'2411 glenview', 1, CAST(0x0000A7D200D01458 AS DateTime), N'U100955369', N'P606913025', N'absolute', N'1037px', N'535px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'e42176b9-4294-8556-f348-b3eba0f57cd3', N'william public note', 1, CAST(0x0000A7D200D0499E AS DateTime), N'U100955369', NULL, N'absolute', N'-76px', N'630px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'e4459594-ba39-883d-820c-408e787ff808', N'GEORGE 1ST PROPERTY PUBLIC NOTE', 1, CAST(0x0000A7CC008E66A6 AS DateTime), N'U889546954', N'P660086996', N'absolute', N'931px', N'894px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'ee77d4c9-cb34-3b96-83c3-c21ae8bf2fe4', N'JOHN STARK HOMES NOTE', 1, CAST(0x0000A7F400500898 AS DateTime), N'U831603621', N'P667672818', N'absolute', N'1147px', N'331px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'f2e073f2-13ad-f634-6f7a-7e3198f4ee99', N'CALL CHAU FOR OPEN HOUSE&nbsp;', 0, CAST(0x0000A7BB00F7B6DA AS DateTime), N'U831603621', N'P129699116', N'absolute', N'454px', N'579px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'f4318fc8-af73-effc-2154-3dc59a86e486', N'<span style="color: rgb(1, 82, 73); font-family: Raleway, Helvetica; font-size: 25px; background-color: rgb(255, 255, 255);">12950 Robleda Rd, Los Altos Hills, CA</span>', 1, CAST(0x0000A7F60169FF06 AS DateTime), N'U831603621', N'P062160271', N'absolute', N'1101px', N'721px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'f879da23-643a-5977-87dd-d2c11dddb3b9', N'CHECK OUT OPEN HOUSE TODAY', 1, CAST(0x0000A7BB00F7C871 AS DateTime), N'U831603621', N'P129699116', N'absolute', N'655px', N'579px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'fa73d1f2-7fc1-8da5-9889-1df6776770e9', N'test new prop note', 1, CAST(0x0000A7F30030B653 AS DateTime), N'U831603621', N'P486648303', N'absolute', N'10px', N'10px')
INSERT [dbo].[Notes_tbl] ([Id], [NoteText], [IsPublic], [CreatedDate], [CreatedBy], [PropertyId], [Position], [posX], [PosY]) VALUES (N'fbc52e32-997f-f973-de05-c180fab1f07e', N'india finest property now available', 1, CAST(0x0000A7D20076DBF5 AS DateTime), N'U889546954', N'P595991847', N'absolute', N'485px', N'737px')
SET IDENTITY_INSERT [dbo].[Page] ON 

INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (1, N'About', N'About Us', N'About Us', N'<div class="col-md-12" style="height: 50px;"><span style="font-size: 18pt;"><strong>&nbsp;</strong></span></div>
<div class="col-md-12">
<div class="col-md-12">
<p><span style="color: #bba56d; font-size: 14pt;"><strong>About Us</strong></span></p>
<p>Gryphons were&nbsp;known for guarding treasure and priceless possessions just like the mythical character we also aim to protect our clients assets and safeguard&nbsp;their prised possessions.</p>
<p>We have over 20 years of market experienece which&nbsp;enables us to offer our clients a more bespoke service. Our company works hard to build trust and business relations.</p>
<p>Gryphon Estates are committed to providing an unrivalled customer experience. This is achieved through our professional service in which we strive to achieve the best possible results for our clients.</p>
<br /><br /></div>
</div>', NULL)
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (2, N'Stamp', N'Stamp Duty', N'Stamp Duty', N'<div class="wpb_wrapper">
<h3 class="vc_custom_heading" style="text-align: left; font-family: Roboto; font-style: normal;">What is Stamp Duty land tax (SDLT)?</h3>
<br />
<div class="wpb_text_column wpb_content_element ">
<p>Stamp Duty Land Tax is the tax that the government charges when you purchase a home over &pound;125,000. You pay different rates depending on the value of your home. You can find how much your Stamp Duty tax is by using our stamp duty calculator.</p>
<div class="vc_empty_space" style="height: 0px;">&nbsp;</div>
</div>
</div>
<div class="vc_row wpb_row vc_row-fluid">
<div class="wpb_column vc_column_container vc_col-sm-12">
<div class="wpb_wrapper">
<h3 class="vc_custom_heading" style="text-align: left; font-family: Roboto; font-style: normal;">New changes to Stamp Duty from 1st April 2016,when buying a UK second home or buy to let property the UK?</h3>
<div class="wpb_text_column wpb_content_element  howtopay">
<div class="wpb_wrapper">
<p>From the 1st April 2016 anyone purchasing a property in addition to their main home has to pay an additional 3% SDLT for the first &pound;125,000 and 5% instead of 2% on the portion between &pound;125,001 and &pound;250,000 and 8% on the amount above &pound;250,001.</p>
</div>
</div>
</div>
</div>
</div>
<h3>Buy to Let or second home SDLT bands</h3>', N'<div class="vc_row wpb_row vc_row-fluid">
<div class="wpb_column vc_column_container vc_col-sm-12">
<div class="wpb_wrapper">
<h3 class="vc_custom_heading" style="text-align: left; font-family: Roboto; font-style: normal;">Paying the higher SDLT</h3>
<div class="wpb_text_column wpb_content_element  howtopay">
<div class="wpb_wrapper">
<p>Under the new proposals, all property owners purchasing an additional property to their main residence in England, Wales and Northern Ireland are likely to be subject to the rise in SDLT. If you already own properties but plan to buy a permanent home to replace another, you are exempt from the paying the higher rate.</p>
<p>If you own two properties on the day of completion of the purchase of your second property but still legally own your first property and plan to sell, you are still obliged to pay the higher rate of SDLT. A refund is available if you sell your former residence property within 36 months.</p>
<p>When applying the higher rates, a small share (50% or less) in a property which has been inherited within the 36 months prior to a transactionit will not be considered as an additional property.</p>
</div>
</div>
<div class="vc_empty_space">&nbsp;</div>
<div class="vc_empty_space">&nbsp;</div>
</div>
</div>
</div>
<div class="vc_row wpb_row vc_row-fluid">
<div class="wpb_column vc_column_container vc_col-sm-12">
<div class="wpb_wrapper">
<h3 class="vc_custom_heading" style="text-align: left; font-family: Roboto; font-style: normal;">How to pay Stamp Duty?</h3>
<div class="wpb_text_column wpb_content_element  howtopay">
<div class="wpb_wrapper">
<p>You will need to submit a Stamp Duty Land Tax return to HMRC and pay within 30 days of completion. You are responsible to ensure that the return is completed on time, although most people have a solicitor or a conveyancer to do this for them.</p>
</div>
</div>
<div class="vc_empty_space" style="height: 30px;">&nbsp;</div>
<div class="vc_empty_space" style="height: 30px;">&nbsp;</div>
</div>
</div>
</div>')
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (3, N'Shortlets', N'Short lets', N'Short lets', N'<h2 style="color: #bba56d;">Short Lets</h2>
<p><strong style="color: #bba56d;">Gryphon Estates</strong> provides a professional short let service, which offers flexibility to landlords and convenience to tenants.</p>
<p>We work with corporate organizations and businesses that regularly use our services to accommodate their employees.</p>
<h3>What is short letting?</h3>
<p>A short let is a property that can be let for a short term from 4 weeks and above. The rent includes all bills such as electricity, water, heating and council tax from 4 weeks and above without having to pay a deposit on the flat.</p>
<h3>Why choose a short let?</h3>
<p>A short let is a cheaper alternative to hotel accommodation or serviced apartments. It does not require long term planning and commitment.</p>
<h3>Some Benefits to Landlords</h3>
<ul>
<li>Increase flexibility of letting your property for shorter periods of time.</li>
<li>Maximise your income from a second or empty property.</li>
<li>High rents achieved.</li>
<li>No need to change utility contracts.</li>
<li>Guaranteed trusted corporate tenants</li>
</ul>
<h3>Some Benefits to Tenants</h3>
<ul>
<li>Ready to move into.</li>
<li>No utility or service contracts to set up or bills to pay.</li>
<li>Sometimes can be cheaper than hotels.</li>
<li>Can benefit those tenants that are in-between properties.</li>
<li>A professionally managed property with immediate response team at hand.</li>
</ul>
<p><strong>Call us on 020 8983 1122 or email us on contact@gryphonestates.com.</strong></p>
<p><br /> </p>', NULL)
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (4, N'Tenant', N'Tenants', N'Tenants', N'<div class="col-md-8">
<div class="wpb_column vc_column_container">
<div class="wpb_wrapper">
<h3 style="color: #bba56d;">Services for tenants</h3>
<p>Gryphons Estates are here to help and guide the tenants and make the renting procedure as smooth as possible.</p>
<p>Wheather you are moving from abroad or need a temporary accomodation we will try and help you and find the best home for your situation.</p>
<p>All our rates are outlined from the beginning and we work to strict standards to insure that everything is done promptly and fairly.</p>
<p>Please see here our <a href="http://gryphonestate.goigi.com/images/TENANTS%20FEE%E2%80%99s.pdf">Tenant fees.</a></p>
<p>If you have any questions please do not hesitate to contact us on 0208 983 1122 or email <a href="#">contact@gryphonestates.com</a></p>
</div>
</div>
</div>
<div class="col-md-4">
<div class="wpb_wrapper">
<div class="wpb_text_column wpb_content_element vc_custom_1452594518178">
<div class="wpb_wrapper">
<p><img class="img-responsive" style="margin-left: 30%;" src="../../Content/img/tenants/3.jpg" alt="House" width="75%" height="200" /></p>
</div>
</div>
</div>
</div>', NULL)
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (5, N'PropertyManagement', N'Property Management', N'Property Management', N'<div class="col-md-12">
<div class="col-md-6">
<h1>Property Management</h1>
<p>Gryphon Estates act as the landlord removing the strain of letting your property. We offer a meticulous lettings management service. At Gryphons we understand that as a landlord, its simply not enough to achieve the best possible rent for your property but also have the assurance your asset is well protected. This is why many landlords looking for an outstanding service, reliability and a professional approach to property management trust Gryphon estates.</p>
<p>Gryphon estatesmanage a range of property, from individual homes to investment portfolios.</p>
<p>Our service is designed to suit you, we recognise that each client has their own unique requirements: an institutional landlord will require a very different service to an individual investor, family trust or overseas landlord.</p>
<p>So at Gryphons Estate there&rsquo;s no such thing as a standard service - instead we offer a bespoke service that&rsquo;s tailored to each client&rsquo;s individual needs. We place great emphasis on landlord care and value the long term relationships that we have built.</p>
</div>
<div class="col-md-6">
<div class="row">
<div id="myCarousel" class="carousel slide" data-ride="carousel"><!-- Indicators --> <!-- Wrapper for slides -->
<div class="carousel-inner">
<div class="item active"><img class="img-responsive" src="../../Images/gallery/I893868161.jpg" alt="House" width="NaN" height="350" /></div>
<div class="item"><img class="img-responsive" src="../../Images/gallery/I401984130.jpg" alt="Apartment1" width="NaN" height="350" /></div>
<div class="item"><img class="img-responsive" src="../../Images/gallery/I430585441.jpg" alt="Apartment2" width="NaN" height="350" /></div>
<div class="item"><img class="img-responsive" src="../../Images/gallery/I430585441.jpg" alt="Apartment3" width="NaN" height="350" /></div>
</div>
<!-- Left and right controls --> <a class="left carousel-control" href="#myCarousel" data-slide="prev"> <span class="sr-only">Previous</span> </a> <a class="right carousel-control" href="#myCarousel" data-slide="next"> <span class="sr-only">Next</span> </a></div>
<div class="col-md-12">&nbsp;</div>
</div>
</div>
</div>
<div class="col-md-12" style="height: 50px;">&nbsp;</div>
<div class="col-md-12">
<div class="col-md-6">@*
<div><iframe style="height: 400px; width: 500px;" src="https://www.youtube.com/embed/MgsdblVq8wo?feature=oembed" width="300" height="150" frameborder="0" allowfullscreen="allowfullscreen"></iframe></div>
*@
<div class="row">
<div class="col-md-4"><img style="height: 120px; width: 170px; border: solid 2px white;" src="../../Content/img/Shortlet/1.jpg" alt="" /></div>
<div class="col-md-4"><img style="height: 120px; width: 170px; border: solid 2px white;" src="../../Images/gallery/I775252986.jpg" alt="" /></div>
<div class="col-md-4"><img style="height: 120px; width: 170px; border: solid 2px white;" src="../../Images/gallery/I893868161.jpg" alt="" /></div>
</div>
<div class="row" style="margin-bottom: 15px;">
<div class="col-md-4"><img style="height: 120px; width: 170px; border: solid 2px white;" src="../../Images/gallery/I401984130.jpg" alt="" /></div>
<div class="col-md-4"><img style="height: 120px; width: 170px; border: solid 2px white;" src="../../Images/gallery/I385803056.jpg" alt="" /></div>
<div class="col-md-4"><img style="height: 120px; width: 170px; border: solid 2px white;" src="../../Images/gallery/I865797233.jpg" alt="" /></div>
</div>
</div>
<div class="col-md-6">
<h3>We provide</h3>
<ul>
<li>Comprehensive support and advice,</li>
<li>Organise tenancies</li>
<li>Property refurbishment</li>
<li>Property maintenance</li>
<li>Rent collection and service charges and dealing with terminations.</li>
<li>Timely transfer of rent - rigorous financial controls enable us to take swift action on any late payments</li>
<li>Cost-effective, responsive and friendly service that makes your landlord experience hassle-free</li>
<li>GryphonAnnual safety checks</li>
<li>Managing terminations and tenancy renewals</li>
<li>Obtaining references</li>
<li>Rent collection and deposit protection</li>
<li>Utility transfers</li>
<li>Pre and post tenancy repairs and maintenance</li>
<li>Annual property inspections</li>
<li>Management whilst property is vacant between tenancies</li>
</ul>
<p>Our Property Management Department can be contacted on 0208 983 1122 or emailed on contact@gryphonestates.com</p>
</div>
</div>
<div class="col-md-12" style="height: 50px;">&nbsp;</div>', NULL)
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (6, N'Investing', N'Investing', N'Investing', N'<h2 style="color: #bba56d;">Investments</h2>
<p>At <strong style="color: #bba56d;">Gryphon Estates</strong> we offer a property sourcing service which is a bespoke facility for clients looking for a more efficient way to purchase property whilst avoiding any conflicts of interest. Whether you are looking to expand your investment portfolio or find a new family home, our sourcing teamwork on your behalf to guide you towards your perfect purchase.</p>
<ul>
<li>Our specialist property sourcing team uses its wealth of industry experience to offer clients an insight to the different types of property, areas and rental markets.</li>
<li>We can offer a &lsquo;one-stop shop&rsquo; for rental investors, handling the purchase, refurbishment, marketing, renting, maintenance and eventual sale of a property.</li>
<li>Our agents focus on the client&rsquo;s needs and appreciate their limited availability and time frames, especially if outside the UK.</li>
<li>Free advice on the different local areas via our London offices.</li>
<li>Access to important industry contacts.</li>
<li>No conflict of interest.</li>
<li>Access to off-market properties, repossessions and pro-bate properties.</li>
<li>Competitive fees of 1% + VAT</li>
</ul>', NULL)
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (7, N'Commercial', N'Commercial', N'Commercial', N'<div class="col-md-12">
<div class="col-md-12">
<h1 style="color: #baa56c;">Gryphon Commercial</h1>
<p>GryphonCommercial is an expanding team with an excellent reputation for its bespoke approach and commitment to its clients.</p>
<p>With a wealth of experience in retail, offices, industrial, care and leisure sectors we provide independent advice to our commercial property clients our services include:</p>
<ul>
<li>All aspects of landlord and tenant work, specifically commercial agency for clients seeking to let or sell a commercial.</li>
<li>Business transfer services for clients seeking a confidential or open market sale of their</li>
<li>Commercial land acquisition</li>
<li>Good network of developers and International investors</li>
<li>Commercial development appraisal</li>
<li>Bespoke consultancy</li>
<li>Property management</li>
</ul>
<p>Gryphons Commercial department operate by strict rules of conduct to ensure we offer you the highest level of integrity and service.</p>
<p>If you are seeking advice for your business or property and would like an experienced professional dedicated to meeting your objectives, please contact us contact@gryphonestates.com or on 0208 983 1122.</p>
<p>If you are seeking advice for your business or property and would like an experienced professional dedicated to meeting your objectives, please call us.</p>
</div>
</div>', NULL)
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (8, N'CommercialClasses', N'Commercial Classes', N'Commercial Classes', N'<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">A1 Shops - Class I</button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Shops, retail warehouses, hairdressers, undertakers, travel and ticket agencies, post offices, dry cleaners, etc Pet shops, cats-meat shops, tripe shops, sandwich bars Showrooms, domestic hire shops, funeral directors Order 1998 - No permitted change</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">A2 Financial and Professional Services - Class II </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Banks, building societies, estate and employment agencies Professional and financial services, betting offices</p>
<p>Order 1998 - Permitted change to A1 where a ground floor display window exists</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">A3 Food and Drink</button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Restaurants, pubs, snack bars, caf&eacute;s, wine bars, shops for sale of hot food</p>
<p>Order 1998 - Permitted change to A1 or A2</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">Sui Generis </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Shops selling and/or displaying motor vehicles</p>
<p>Order 1998 - Permitted change to A1</p>
<p>Launderettes, taxi or vehicle hire businesses, amusement centres, petrol filling stations</p>
<p>Order 1998 - No permitted change</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">B1 Business - Class II &amp; Class III </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Offices, not within A2, Research and development studios, laboratories, high tech Light industry</p>
<p>Permitted change to B8 where no more than 235sqm</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">B2 General Industrial - Class IV-IX </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>General industrial</p>
<p>Order 1998 - Permitted change to B1 or B8 limited to no more than 235 sqm</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">B8 Storage and distribution - Class X </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Wholesale warehouse, distribution centres, repositories</p>
<p>Order 1998 - Permitted change to B1 where no more than 235 sqm</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">Sui Generis </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Any work register able under the Alkali, etc. Works Regulation Act, 1906</p>
<p>Order 1998 - No permitted change</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">C1 Hotels - Class XI </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Hotels, boarding and guest houses</p>
<p>Order 1998 - No permitted change</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">C2 Residential Institutions - Class XII &amp; Class XIV </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Residential schools and colleges Hospitals and convalescent/nursing homes</p>
<p>Order 1998 - No permitted change</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">C3 Dwelling Houses</button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Dwellings, small businesses at home, communal housing of elderly and handicapped (Six or less residents unless living together as a family.)</p>
<p>Order 1998 - No permitted change</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">Sui Generis </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Hostel</p>
<p>Order 1998 - No permitted change</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">D1 Non-residential Institutions - Class XIII, Class XV &amp; Class XVI </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Places of worship, church halls Clinics, health centres, cr&egrave;ches, day nurseries, consulting rooms Museums, public halls, libraries, art galleries, exhibition halls Non-residential education and training centres</p>
<p>Order 1998 - No permitted change</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">D2 Assembly and Leisure - Class XVII &amp; Class XVIII </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Cinemas, music and concert halls Dance, sports halls, swimming baths, skating rinks, gymnasiums Other indoor and outdoor sports and leisure uses, bingo halls, casinos</p>
<p>Order 1998 - No permitted change</p>
</div>
</div>
</div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="col-sm-12"><button class="btn btn-3 btn-3a headb">Sui Generis - Class XVII </button></div>
</div>
</div>
<div class="row">
<div class="col-sm-10 col-sm-push-1">
<div class="owl-carousel owl-theme" style="opacity: 1; display: block;">
<div class="owl-wrapper-outer margintopbottom">
<div class="col-sm-12">
<p>Theatres</p>
<p>Order 1998 - No permitted change</p>
</div>
</div>
</div>
</div>
</div>', NULL)
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (9, N'OverseaProperty', N'Oversea Property', N'Oversea Property', N'<p><strong style="color: #bba56d;">Gryphon Estates</strong> work closely with agents and property developers across the globe to offer properties for sale in various locations around the world.</p>
<p>This means we are able to offer significant and sustainable rental returns as well as capital growth opportunities for our customers.</p>
<p>So, whether you&rsquo;re new to property investment or looking to expand your existing portfolio contact us today to discuss your requirements.</p>
<p><br /><br /></p>', NULL)
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (10, N'Sales Guide', N'Sales Guide', N'Sales Guide', N'<div class="col-md-12">
<h2 style="color: #bba56d;">Sales Guide</h2>
<h3>Step-by-step guide to buying property</h3>
<p>Buying a property can be a complicated process. This step-by-step guide has been designed to walk you through the process of buying property.</p>
<div class="col-md-12">
<div class="col-md-2">&nbsp;</div>
<div class="col-md-8"><img class="img-responsive" src="Images/bbb.png" alt="" /></div>
<div class="col-md-2">&nbsp;</div>
</div>
<h3>Step 1 Arranging your mortgage</h3>
<p>Before you begin your property search, it is advisable to arrange your finances and, if required, have a mortgage agreed in principle. This will confirm how much money you will have to fund the purchase, which will ultimately influence your property search.</p>
<p>Our recommended mortgage broker, Kevin Hogan, has access to the entire market, as well as exclusive deals and rates to help find you the best mortgage available.</p>
<h3>Step 2 Register your interest</h3>
<p>The first step to finding the right property is to contact us by either calling, emailing or visit one of our offices.</p>
<h3>Step 3 Finding the right property</h3>
<p>Once we have a clear understanding of your requirements you will receive a selection of properties that match your criteria. We can also keep you constantly up-to-date via email and SMS alerts when the latest properties become available.</p>
<p><strong>Search for a new property to buy</strong></p>
<h3>Step 4 The key to successful viewings</h3>
<p>We''re open at times to suit you, convenient for viewing after work, at weekends and bank holidays.</p>
<p>In order to secure a property we recommend an early viewing. We will chauffeur you to your viewings ensuring you arrive in a relaxed frame of mind and accompany you throughout so that we are on hand to answer any questions immediately and advise where necessary.</p>
<h3>Step 5 Instructing a solicitor</h3>
<p>The successful purchase of a property can be reliant on the instruction of an efficient and experienced solicitor. It is a good idea to use a solicitor who knows the area that you''re moving to and specialises in conveyancing.</p>
<p>We have a selection of tried and tested solicitors that are experts in property who we would be happy to recommend.</p>
<h3>Step 6 Making an offer</h3>
<p>Once you have identified a suitable property we will put your offer forward to the seller both verbally and in writing stating any special conditions of the offer. You may need to demonstrate, if requested, that you are able to proceed (e.g. provide evidence of your mortgage agreed in principle).</p>
<p>There are no legal obligations on either side until contracts are signed.</p>
<h3>Step 7 Offer agreed</h3>
<p>Once your offer is accepted we will do the following:</p>
<ul>
<li>Prepare a memorandum of sale</li>
<li>Write to all parties to confirm the agreed price</li>
<li>Ask you to confirm your solicitor''s and mortgage broker''s details</li>
</ul>
<p>You will now need to instruct your solicitor to proceed with the conveyancing process and your <span style="text-decoration: underline;">mortgage broker</span> to proceed with your application.</p>
<h3>Step 8 Conveyancing</h3>
<p>As part of the conveyancing process your solicitor will do the following:</p>
<ul>
<li>Raise any additional enquiries on receipt of the draft contract from the seller''s solicitor</li>
<li>Request their own local searches</li>
<li>Agree on a date for exchange of contracts</li>
</ul>
<p>We will assist your solicitor and negotiate throughout the process, keeping you informed every step of the way.</p>
<h3>Step 9 Survey and mortgage offer</h3>
<p>A survey of the property will be booked by a surveyor on behalf of the mortgage lender to identify any structural problems and advise on the property''s value.</p>
<p>After the mortgage valuation report is received, a formal mortgage offer will be sent to you and your solicitor which you will need to sign before it is returned.</p>
<p>There are no legal obligations until contracts are signed.</p>
<h3>Step 10 Exchange of contracts</h3>
<p>Exchange of contracts occurs when all enquiries have been confirmed and agreed.</p>
<p>Once the contract has been signed by both parties the deposit (usually 10% of the purchase price) will be telegraphically transferred or paid in the form of a banker''s draft from your solicitor to the seller''s solicitor.</p>
<p>The completion date is then set by mutual agreement.</p>
<h3>Step 11 Completion</h3>
<p>Completion is when the residual monies (usually 90%) are transferred from your solicitor to the seller''s solicitor''s account.</p>
<p>We will release the keys once the money has cleared in the seller''s account.</p>
<p>Congratulations, you are now the legal owner of your new home!</p>
<br /><br /></div>', NULL)
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (11, N'Letting Guide', N'Letting Guide', N'Letting Guide', N'<div class="col-md-12">
<h2 style="color: #bba56d;">Letting Guide</h2>
<h3>A step-by-step guide to letting your property</h3>
<p>Backed by an extensive knowledge of the local market and commercially astute investment advice, our lettings team provides dedicated and proactive property management to landlords.</p>
<p>Our continually updated databases ensure our ability to match qualified tenants with suitable properties and quickly.</p>
<p>With services such as stringent inspections and strategic marketing plans as well as lease agreements, rent reviews and property maintenance, we deliver high occupancy rates with total peace of mind.</p>
<div class="col-md-12">
<div class="col-md-2">&nbsp;</div>
<div class="col-md-8"><img class="img-responsive" src="Images/aaa.png" alt="" /></div>
<div class="col-md-2">&nbsp;</div>
</div>
<h3>Step 1 Accurate valuation</h3>
<p>Your aim should be to let your property at the best possible price in the shortest possible time. Our expert valuers carry out thousands of valuations every month, giving us intimate and unparalleled knowledge of property values in your area. This is why we consistently achieve the asking price across all our clients'' properties.</p>
<p>Call us on 0208 983 1122 or complete the valuation request form.</p>
<a href="@Url.Action(">Request a valuation</a>
<h3>Step 2 Selecting an estate agent</h3>
<p>When choosing a letting agent consider their <strong>opening hours</strong>, when they will be available to <strong>conduct viewings</strong>, their <strong>high street presence</strong> and what kind of <strong>marketing your property</strong> will receive. These are critical to obtaining the maximum rental value for your property.</p>
<p>You should also check if your agent will organise your government-required Energy Performance Certificate (EPC) on your behalf or if you need to arrange this yourself. You are responsible for making this document available to prospective and future tenants. Gryphon estates can arrange this for you.</p>
<h3>Step 3 Benefits of Corporate Services</h3>
<p>Gryphon estates Corporate Services assists city companies who are looking to find properties for their employees.</p>
<p>Letting your property through this specialist department has the benefit of a wide variety of applicants from reputable companies, willing to pay a premium for high levels of service and peace of mind.</p>
<h3>Step 4 Consider property management</h3>
<p>Property management can be the key to reaping maximum rental returns on your property. Many tenants insist on renting managed properties and are often prepared to pay a premium for this.</p>
<p>Instructing Gryphon estates to manage your property gives you peace of mind that both your property and tenant will be cared for 24/7. Your dedicated Property Manager will look after the general day-to-day management and more complex issues such as emergency repairs, collection of rent, transfer of utilities and much more.</p>
<h3>Step 5 Presenting your property</h3>
<p>First impressions count, making the presentation of your property critical to a successful let. Consider addressing any DIY jobs you have been meaning to get done, add a fresh coat of paint where necessary and try to declutter to make rooms appear larger.</p>
<p>Gryphon estates'' team of dedicated professional ''Photographers'' will then take photographs, create 360&deg; tours, produce interactive floorplans and write comprehensive property descriptions, all in just one visit.</p>
<h3>Step 6 Preparing your property for tenancy</h3>
<p>Before you let your property for the first time you must obtain a professional and comprehensive inventory. This will set out the condition and contents of the property. Gryphon estates'' will carry out a professional inventory on your behalf.</p>
<p><strong>Long term tenancies (6 months or more)</strong><br /> You are responsible for checking that the tenants have set up accounts with utility companies, telephone supplier, council tax and TV licensing.</p>
<h3>Step 7 Marketing your property</h3>
<p>To find your perfect tenant you need to give your property maximum exposure across a wide range of media.</p>
<p>When you <span style="text-decoration: underline;">instruct Gryphon estates to let your property</span> you will automatically benefit from our unrivalled, comprehensive marketing package, including: exposure on our website, full colour property details, inclusion in our monthly area magazines and key property titles, email and SMS alerts and PR.</p>
<h3>Step 8 Accompanied viewings</h3>
<p>Our longer opening hours are essential to maximise viewing opportunities for your property - in fact over 40% of our viewings are carried out after work and at weekends. Accompanied viewings also mean we can use our expertise to help let your property.</p>
<p>Our offices are open 9am-8pm Monday to Friday and 9am-5pm Saturdays, Sundays and Bank Holidays. In addition, our phone lines are open 8am-8pm, 7 days a week.</p>
<h3>Step 9 Receiving an offer</h3>
<p>As Soon as an offer is received we will contact you to communicate full details of the offer along with any special conditions to help you decide whether or not to accept.</p>
<h3>Step 10 Offer agreed</h3>
<p>Once you accept an offer we will do the following, regardless of whether your property is managed:</p>
<ul>
<li>Collect references from the tenants</li>
<li>Arrange signing of the Tenancy Agreement</li>
<li>Collect moving-in payment (rent + deposit)</li>
</ul>
<p>We can also, subject to a fee, get your property ready for move-in and:</p>
<ul>
<li>Carry out check-in and inventory</li>
<li>Organise Gas Safety Inspection and Portable Appliance test</li>
<li>Arrange professional cleaning of your property</li>
</ul>
<p>For your added peace of mind, where applicable we will hold the deposit as a stakeholder and register this with a deposit protection scheme, resulting in a faster and more efficient deposit release process at the end of the tenancy.</p>
<h3>Step 11 Completion</h3>
<p>Upon completion, keys will be released to the inventory clerk or the tenant on moving-in day.</p>
<p>For managed properties, we will provide the tenant with contact details of their dedicated Property Manager.</p>
<p>Congratulations, your property is now let!</p>
<br /><br /></div>', NULL)
INSERT [dbo].[Page] ([id], [Page_Name], [Page_Title], [Page_Heading], [Page_Content], [Page_Content2]) VALUES (12, N'Landlord', N'Landlord', N'Landlord', N'<div class="col-md-12">
<h2 style="color: #bba56d;">Landlord</h2>
<p>Letting your property can be a complex and demanding process. Let us take the stress out of being a landlord, ensuring you a maximum rental income while walking you through financial and legal obligations.</p>
<p>We are continually updating our databases to ensure our ability to match qualified tenants with suitable properties.</p>
<p>With our extensive knowledge of the local markets and commercially astute investment advice, our lettings teams can provide dedicated and proactive property management to our landlords.</p>
<p>We deliver high occupancy rates with total peace of mind.</p>
<p>You can be confident your investment will stay safe and secure in our care.</p>
<p>Please see here our <a href="#">Landlords fee schedule.</a></p>
<p>If you have any questions please do not hesitate to contact us on 0208 983 1122 or email contact@gryphonestates.com</p>
<br /> </div>', NULL)
SET IDENTITY_INSERT [dbo].[Page] OFF
INSERT [dbo].[PriceHistory_tbl] ([PriceId], [Date], [Event], [Price], [Price_Sqft], [Source], [PropertyId], [Entry_Date]) VALUES (N'P003382669', CAST(0x0000A4CF00000000 AS DateTime), N'Local', CAST(750.000 AS Decimal(18, 3)), CAST(300.000 AS Decimal(18, 3)), N'Agent', N'P908594713', CAST(0x0000A78D0066D688 AS DateTime))
INSERT [dbo].[PriceHistory_tbl] ([PriceId], [Date], [Event], [Price], [Price_Sqft], [Source], [PropertyId], [Entry_Date]) VALUES (N'P049909928', CAST(0x0000A78E00000000 AS DateTime), N'local', CAST(375.450 AS Decimal(18, 3)), CAST(200.000 AS Decimal(18, 3)), N'Agent', N'P098421340', CAST(0x0000A78D00B045B4 AS DateTime))
INSERT [dbo].[PriceHistory_tbl] ([PriceId], [Date], [Event], [Price], [Price_Sqft], [Source], [PropertyId], [Entry_Date]) VALUES (N'P074970230', CAST(0x0000A84100000000 AS DateTime), N'Local', CAST(750.000 AS Decimal(18, 3)), CAST(30.000 AS Decimal(18, 3)), N'Agent', N'P258950078', CAST(0x0000A78D006B75AD AS DateTime))
INSERT [dbo].[PriceHistory_tbl] ([PriceId], [Date], [Event], [Price], [Price_Sqft], [Source], [PropertyId], [Entry_Date]) VALUES (N'P198031045', CAST(0x0000A78D00000000 AS DateTime), N'local', CAST(754.650 AS Decimal(18, 3)), CAST(450.000 AS Decimal(18, 3)), N'Owner', N'P098421340', CAST(0x0000A78D00B0BA6F AS DateTime))
INSERT [dbo].[PriceHistory_tbl] ([PriceId], [Date], [Event], [Price], [Price_Sqft], [Source], [PropertyId], [Entry_Date]) VALUES (N'P250407571', CAST(0x0000A63D00000000 AS DateTime), N'Local', CAST(451.000 AS Decimal(18, 3)), CAST(200.000 AS Decimal(18, 3)), N'Owner 6666', N'P734344605', CAST(0x0000A78D0066917A AS DateTime))
INSERT [dbo].[PriceHistory_tbl] ([PriceId], [Date], [Event], [Price], [Price_Sqft], [Source], [PropertyId], [Entry_Date]) VALUES (N'P534666389', CAST(0x0000A7DA00000000 AS DateTime), N'234234', CAST(1000.000 AS Decimal(18, 3)), CAST(654.000 AS Decimal(18, 3)), N'APX', N'P493110717', CAST(0x0000A7DA00CBBBAB AS DateTime))
INSERT [dbo].[PriceHistory_tbl] ([PriceId], [Date], [Event], [Price], [Price_Sqft], [Source], [PropertyId], [Entry_Date]) VALUES (N'P914870352', CAST(0x0000A4B000000000 AS DateTime), N'Social', CAST(900.000 AS Decimal(18, 3)), CAST(450.000 AS Decimal(18, 3)), N'Agent', N'P569146898', CAST(0x0000A78D00670818 AS DateTime))
SET IDENTITY_INSERT [dbo].[Profile_Info] ON 

INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (1, N'U831603621', NULL, N'888-888-8888', N'500 INDEPENDENT RD. OAKLAND, CA. 94621', N'OAKLAND', N'ALAMEDA', N'USA', N'94621', N'02122017121256502_5.jpg', N'MALE', NULL, CAST(0xAC3D0B00 AS Date), NULL, NULL, N'<span style="background-color: rgb(255, 255, 0);">THE BEST AGENT IN TOWN</span>', NULL, NULL, NULL, N'JOHNREALESTATES')
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (2, N'U679844771', NULL, N'9876543210', N'New York, NY, United States', N'New York', N'NY', N'United States', N'70021', N'07122017185105814_6.jpg', N'MALE', NULL, CAST(0x9D3D0B00 AS Date), NULL, NULL, N'matt henry about me ', NULL, NULL, NULL, N'MattyRealEstates')
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (3, N'U064962753', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (4, N'U616637881', NULL, N'12346545', N'Sydney, New South Wales, Australia', N'Sydney', N'NSW', N'Australia', N'2000', N'09062017053135073_4.jpg', N'MALE', NULL, CAST(0xE83C0B00 AS Date), NULL, NULL, NULL, NULL, NULL, NULL, N'Joe')
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (5, N'U097531010', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (6, N'U528509529', NULL, N'9153131372', N'480 South Batavia Street, Orange, CA, United States', N'Orange', N'CA', N'United States', N'92868', N'21062017232528234_5.jpg', N'FEMALE', NULL, CAST(0xF43C0B00 AS Date), NULL, NULL, N'vvhrtf', NULL, 33.7812406, -117.8628021, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (7, N'U974389827', NULL, NULL, N'123 B Street, Hayward, CA, United States', NULL, NULL, NULL, NULL, N'06072017222434623_8.jpg', N'MALE', NULL, CAST(0x033D0B00 AS Date), NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (8, N'U501082657', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (9, N'U840729486', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (10, N'U014877963', NULL, NULL, N'Testour, Beja, Tunisia', N'Testour', N'Beja', N'Tunisia', NULL, N'06072017054945343_7.jpg', N'MALE', NULL, CAST(0x033D0B00 AS Date), NULL, NULL, NULL, NULL, 36.5499, 9.44226639999999, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (12, N'U052555274', NULL, NULL, N'New York 6th Ave, NY, United States', N'New York', N'NY', N'United States', N'10014', N'09082017071428717_9.jpg', N'MALE', NULL, CAST(0x253D0B00 AS Date), NULL, NULL, NULL, NULL, 40.7232085, -74.004841, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (13, N'U889546954', NULL, N'123-456-7890', N'1 Heavenly Place, Milpitas, CA, United States', N'Milpitas', N'CA', N'United States', N'95035', N'11082017083455129_10.jpeg', N'MALE', NULL, CAST(0x273D0B00 AS Date), NULL, NULL, N'GEORGE DESCRIPTION', NULL, 37.4200219, -121.8995788, N'GEORGETHEFIRST')
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (14, N'U068476417', NULL, N'123-456-7890', N'1 Grand Avenue, Oakland, CA, United States', N'Oakland', N'CA', N'United States', N'94610', N'03092017231357973_14.png', N'MALE', NULL, CAST(0x3E3D0B00 AS Date), NULL, NULL, N'SELL SELL SELL 

SELL 

SELL', NULL, 37.8114143, -122.2666398, N'BILLYTHESELLER')
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (15, N'U100955369', NULL, N'888-888-8888', N'1 Airport Drive, Oakland, CA, United States', N'Oakland', N'CA', N'United States', N'94621', N'17082017124053197_11.jpg', N'MALE', NULL, CAST(0x2D3D0B00 AS Date), NULL, NULL, N'WILLIAM PROFILE', NULL, 37.7172178, -122.2112161, N'#SUPER AGENT')
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (16, N'U333611123', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (19, N'U239950756', NULL, N'925-888-9189', N'2005 Kalia Road, Honolulu, HI, United States', N'Honolulu', N'HI', N'United States', N'96815', N'07092017093534481_15.jpg', N'MALE', NULL, CAST(0x423D0B00 AS Date), NULL, NULL, N'SUPER AGENT READY FOR ALL YOUR REAL ESTATES NEED

WHENEVER YOU CALL ME, I''LL BE THERE!', NULL, 21.2831832, -157.8367115, N'#SUPERMAN')
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (20, N'U842876075', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (21, N'U572543338', NULL, N'8888888888', N'1 Hamilton Road, Kapolei, HI, United States', N'Kapolei', N'HI', N'United States', N'96707', N'08092017091131808_16.png', N'MALE', NULL, CAST(0x483D0B00 AS Date), NULL, NULL, N'COME JOIN THE WINNING TEAM THAT YOU LEAD YOU TO YOUR DREAM. 

COME JOIN THE WINNING TEAM THAT YOU LEAD YOU TO YOUR DREAM. 

COME JOIN THE WINNING TEAM THAT YOU LEAD YOU TO YOUR DREAM. 


COME JOIN THE WINNING TEAM THAT YOU LEAD YOU TO YOUR DREAM. 




COME JOIN THE WINNING TEAM THAT YOU LEAD YOU TO YOUR DREAM. 



COME JOIN THE WINNING TEAM THAT YOU LEAD YOU TO YOUR DREAM. ', NULL, NULL, NULL, N'#SAVEYOUMONEY')
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (23, N'U317986945', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Profile_Info] ([ProfileSrl], [Profile_Id], [LoginId], [ContactNo], [Address], [City], [State], [Country], [Zip], [Photo], [Gender], [Entry_Date], [Last_Modified_Date], [CreatedBy], [DOB], [AboutMe], [CCode], [Latitude], [Longitude], [ScreenName]) VALUES (24, N'U701938473', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Profile_Info] OFF
SET IDENTITY_INSERT [dbo].[Property_Characteristic_Mapping] ON 

INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (1, 1, N'PID697772120')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (15, 1, N'PID273197018')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (16, 2, N'PID273197018')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (23, 1, N'PID673121833')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (24, 2, N'PID673121833')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (25, 4, N'PID673121833')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (26, 1, N'PID750233421')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (27, 2, N'PID750233421')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (28, 4, N'PID750233421')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (32, 1, N'PID394804404')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (33, 2, N'PID394804404')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (43, 1, N'PID748883003')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (44, 2, N'PID748883003')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (45, 4, N'PID748883003')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (46, 2, N'PID351286816')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (53, 4, N'PID318482922')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (75, 2, N'PID902174238')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (92, 2, N'PID025762092')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (95, 1, N'PID255575781')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (96, 2, N'PID120592268')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (106, 1, N'PID088090219')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (107, 2, N'PID088090219')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (110, 4, N'PID387473731')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (128, 1, N'PID506993370')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (129, 2, N'PID506993370')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (130, 4, N'PID506993370')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (140, 2, N'PID602612757')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (147, 1, N'PID899863423')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (151, 2, N'PID974603615')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (152, 1, N'PID238276778')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (153, 2, N'PID238276778')
INSERT [dbo].[Property_Characteristic_Mapping] ([Id], [CharId], [PropertyId]) VALUES (154, 4, N'PID238276778')
SET IDENTITY_INSERT [dbo].[Property_Characteristic_Mapping] OFF
SET IDENTITY_INSERT [dbo].[Property_Feature_Mapping] ON 

INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (251, N'F055491247', N'P667672818', N'1')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (252, N'F338342725', N'P667672818', N'1')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (253, N'F349971975', N'P667672818', N'1')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (254, N'F417412669', N'P667672818', N'1')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (255, N'F677138400', N'P667672818', N'1')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (308, N'F055491247', N'P062160271', N'17537037')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (309, N'F338342725', N'P062160271', N'5')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (310, N'F417412669', N'P062160271', N'4')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (311, N'F677138400', N'P062160271', N'5')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (10308, N'F055491247', N'P375654081', N'5')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (10309, N'F338342725', N'P375654081', N'5')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (10310, N'F349971975', N'P375654081', N'6')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (10311, N'F417412669', N'P375654081', N'6')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (10312, N'F677138400', N'P375654081', N'8')
INSERT [dbo].[Property_Feature_Mapping] ([id], [FeatureId], [PropertyId], [FeatureValue]) VALUES (20308, N'F055491247', N'P355162091', N'4545')
SET IDENTITY_INSERT [dbo].[Property_Feature_Mapping] OFF
SET IDENTITY_INSERT [dbo].[Property_Images] ON 

INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (4, N'P488497264', N'26042017064438765_13.jpg', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (57, N'P667672818', N'20092017021102050_98.jpg', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (58, N'P667672818', N'20092017021102066_99.jpg', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (59, N'P667672818', N'20092017021102081_100.jpg', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (60, N'P667672818', N'20092017021102097_101.jpg', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (61, N'P062160271', N'22092017132950640_103.jpg', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (62, N'P062160271', N'22092017132950640_104.jpg', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (63, N'P375654081', N'17102017123205622_116.png', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (64, N'P375654081', N'17102017123205629_117.png', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (65, N'P375654081', N'17102017123205634_118.png', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (10063, N'P355162091', N'06112017174552045_116.jpg', NULL)
INSERT [dbo].[Property_Images] ([Id], [PropertyId], [PrpertyImage], [ImageFor]) VALUES (10064, N'P355162091', N'06112017174552051_117.jpg', NULL)
SET IDENTITY_INSERT [dbo].[Property_Images] OFF
INSERT [dbo].[Property_tbl] ([PropertyId], [PropertyFor], [PropertyTypeId], [FrontImage], [Price], [PriceUnit], [Area], [AreaUnit], [PAgeId], [Description], [Address], [City], [State], [PostCode], [Latitude], [Longitude], [Video], [Contact], [CreatedBy], [CreatedOn], [FurnishedStatus], [Property_Status], [Property_Title], [Featured], [IsSold], [MLSNumber], [LOTArea], [LOTAreaUnit], [YearBuilt], [DateOnMarker], [PerAreaPrice], [PerAreaUnit]) VALUES (N'P062160271', N'SALE', N'10004', N'', CAST(19400000.00 AS Decimal(18, 2)), NULL, CAST(5443.00 AS Decimal(18, 2)), N'UN311555433', NULL, N'<div class="zsg-lg-2-3 zsg-sm-1-1 hdp-header-description" id="yui_3_18_1_3_1506107368089_2142" style="display: inline-block; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px 10px 0px 0px; width: 328.656px; color: rgb(68, 68, 68);"><header class="zsg-content-header addr" id="yui_3_18_1_3_1506107368089_2141" style="margin-bottom: 15px;"><h1 class="notranslate" id="yui_3_18_1_3_1506107368089_2140" style="margin-bottom: 5px; color: inherit; font-size: 33px; line-height: 1.17; font-weight: 700;">12950 Robleda Rd,<span class="zsg-h2 addr_city" id="yui_3_18_1_3_1506107368089_2139" style="font-size: 28px; line-height: 1.3; margin-bottom: 5px; display: block;">Los Altos Hills, CA 94022</span></h1><h3 class="" style="margin-right: 0px; margin-bottom: 15px; margin-left: 0px; color: inherit; font-size: 20px; line-height: 1.5; font-weight: 700;"><span class="addr_bbs" style="display: inline-block;">4 beds</span><span class="middle-dot" aria-hidden="true">&nbsp;</span><span class="addr_bbs" style="display: inline-block;">5 baths</span><span class="middle-dot" aria-hidden="true">&nbsp;</span><span class="addr_bbs" style="display: inline-block;">5,440 sqft</span></h3></header></div><div class="zsg-lg-1-3 zsg-md-1-1 hdp-summary" style="display: inline-block; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px 10px; width: 164.328px; margin-top: 3px; float: right; color: rgb(68, 68, 68);"><div id="home-value-wrapper" class="  "><div class="estimates" style="margin-bottom: 15px;"><div class=" status-icon-row for-sale-row home-summary-row" style="font-size: 13px; line-height: 1.5; font-weight: 700; text-transform: uppercase;"><span id="listing-icon" data-icon-class="zsg-icon-for-sale" class="zsg-icon-for-sale for-sale" style="font-size: 10px; line-height: 1; vertical-align: middle;"></span>&nbsp;FOR SALE&nbsp;<span class=""><span class="value-suffix" style="white-space: nowrap; font-size: 15px;"></span></span></div><div class="main-row  home-summary-row" style="font-size: 28px; font-weight: 700; line-height: 1; margin-bottom: 4px;"><span class="">$19,400,000<span class="value-suffix" style="white-space: nowrap; font-size: 15px;"></span></span></div></div><div class="loan-calculator-container"><span class="loan-calculator-label zsg-content_collapsed" aria-label="Estimated Mortgage" style="font-size: 13px; line-height: 1.5; font-weight: bold; text-transform: uppercase; margin-bottom: 0px !important;">EST. MORTGAGE</span><div id="zmm-current-rates" data-30-yr="3.685" data-5-1="3.024" data-15-yr="2.953"></div><div data-property-value="19400000" data-property-zipcode="94022" data-property-city="Los Altos Hills" data-property-image="https://photos.zillowstatic.com/p_e/ISeksvju3u6n200000000000.jpg" data-type="Single Family" id="loan-calculator-container" data-property-hdp-url="https://www.zillow.com/homedetails/12950-Robleda-Rd-Los-Altos-Hills-CA-94022/19527625_zpid/" data-street-address="12950 Robleda Rd"><span class="loan-calculator-estimate" style="vertical-align: middle; font-size: 1.33333rem;"><span class="hlc-output-fixed30">$73,720</span><span aria-label="Per month">/mo</span></span><a data-horizontal-align="right" data-za-action="Calculator open click" data-za-category="Mortgages" id="hdp-calculator-summary-launch" class="zsg-menu-launch calculator-launch zsg-sm-hide za-track-event" data-target-id="react-monthly-payment-calculator-options" data-za-label="HDP:HeaderLoanCalculator" style="background: rgb(255, 255, 255); cursor: pointer; color: rgb(68, 68, 68); position: relative; border: 1px solid rgb(204, 204, 204); border-radius: 3px; padding: 1px 3px; margin-left: 5px; vertical-align: middle;"><span class="zsg-icon-calculator" style="line-height: 1; vertical-align: middle;"></span><span class="zsg-icon-arrow-menu-down" style="line-height: 1; vertical-align: middle; margin-left: 3px;"></span></a></div><div class="partner-link prop-value-mortgage-ad"><a data-za-action="Upsell click" data-za-category="Mortgages" data-zmm-component="HeaderDetailsLink" href="https://www.zillow.com/pre-qualify/#/zipCode=94022&amp;propertyValue=19400000&amp;propertyType=SingleFamilyHome&amp;source=Z_ForsaleHDP_Getpre-approved" class="za-track-event zmm-secure-link" data-za-label="HDP:HeaderDetailsLink" style="background-image: initial; background-position: 0px 0px; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial; cursor: pointer; font-weight: 700; color: rgb(100, 0, 150);">Get pre-qualified</a></div></div></div><div class="lpb-enhancement zsg-content-item" style="margin-bottom: 15px;"><span class="zsg-fineprint" style="font-size: 12px; line-height: 1.5; color: rgb(153, 153, 153); display: block;">Listed by:</span><img width="80" src="https://photos.zillowstatic.com/l_c/ISalaz5mujedy41000000000.jpg" height="40"></div></div><section class="zsg-content-section " id="yui_3_18_1_3_1506107368089_2539" style="margin-bottom: 60px; color: rgb(68, 68, 68); font-family: Gotham, gotham, Verdana, sans-serif;"><div class="zsg-lg-2-3 zsg-md-1-1 hdp-header-description" style="display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; padding: 0px 10px 0px 0px; width: 328.656px;"><div class="zsg-content-component" style="margin-bottom: 30px;"><div class="notranslate zsg-content-item" style="margin-bottom: 15px;">Own this rare &amp; stunning John Cooper Funk Mid-Century Modern home with sweeping views from its hilltop position on 12 very private acres just 1.3 miles, 5 minutes, from downtown Los Altos. Built in 1955, it was faithfully modernized, expanded, and renovated by renowned architect Scott Johnson for an effective age of 17 years. Floor to ceiling glass look upon serene views of meticulously designed gardens and the valley and mountains beyond. Skylight towers and high ceilings invite a cheerful<span id="util_TextFold" class="linkToggle"><span class="closed">…</span>&nbsp;<a class="foldLink closed " style="background-image: initial; background-position: 0px 0px; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial; cursor: pointer; color: rgb(100, 0, 150); display: block;">More&nbsp;<span class="zsg-icon-expando-down" style="line-height: 1; vertical-align: middle; font-size: 12px;"></span></a></span></div></div></div><div class="hdp-facts zsg-content-component z-moreless" id="yui_3_18_1_3_1506107368089_2538" style="margin-bottom: 30px;"><div class="hdp-facts-expandable-container clear" id="yui_3_18_1_3_1506107368089_2547"><p class="hdp-fact-category-title" style="margin-bottom: 15px; font-size: 20px; line-height: 1.5; font-weight: 700;">Facts and Features</p><div class="zsg-g zsg-g_gutterless" style="letter-spacing: -0.31em; text-rendering: optimizeSpeed; font-family: FreeSans, Arimo, &quot;Droid Sans&quot;, Helvetica, Arial, sans-serif; display: flex; flex-flow: row wrap; align-content: flex-start; margin-left: 0px; margin-right: 0px;"><div class="zsg-lg-1-3 zsg-md-1-2" style="display: inline-block; letter-spacing: normal; word-spacing: normal; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px; width: 164.328px;"><div class="hdp-fact-ataglance-container zsg-media" style="zoom: 1; padding: 0px 10px 15px 0px;"><div class="zsg-media-img" style="float: left; margin-right: 15px;"><span class="hdp-fact-ataglance-icon zsg-icon-buildings" style="line-height: 1; vertical-align: middle; display: block; font-size: 28px; padding-top: 8px;"></span></div><div class="zsg-media-bd" style="display: table-cell; vertical-align: top; width: 10000px !important;"><p class="hdp-fact-ataglance-heading" style="margin-bottom: 0px; font-weight: 700;">Type</p><div class="hdp-fact-ataglance-value" style="margin-bottom: 0px;">Single Family</div></div></div></div><div class="zsg-lg-1-3 zsg-md-1-2" style="display: inline-block; letter-spacing: normal; word-spacing: normal; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px; width: 164.328px;"><div class="hdp-fact-ataglance-container zsg-media" style="zoom: 1; padding: 0px 10px 15px 0px;"><div class="zsg-media-img" style="float: left; margin-right: 15px;"><span class="hdp-fact-ataglance-icon zsg-icon-calendar" style="line-height: 1; vertical-align: middle; display: block; font-size: 28px; padding-top: 8px;"></span></div><div class="zsg-media-bd" style="display: table-cell; vertical-align: top; width: 10000px !important;"><p class="hdp-fact-ataglance-heading" style="margin-bottom: 0px; font-weight: 700;">Year Built</p><div class="hdp-fact-ataglance-value" style="margin-bottom: 0px;">2000</div></div></div></div><div class="zsg-lg-1-3 zsg-md-1-2" style="display: inline-block; letter-spacing: normal; word-spacing: normal; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px; width: 164.328px;"><div class="hdp-fact-ataglance-container zsg-media" style="zoom: 1; padding: 0px 10px 15px 0px;"><div class="zsg-media-img" style="float: left; margin-right: 15px;"><span class="hdp-fact-ataglance-icon zsg-icon-heat" style="line-height: 1; vertical-align: middle; display: block; font-size: 28px; padding-top: 8px;"></span></div><div class="zsg-media-bd" style="display: table-cell; vertical-align: top; width: 10000px !important;"><p class="hdp-fact-ataglance-heading" style="margin-bottom: 0px; font-weight: 700;">Heating</p><div class="hdp-fact-ataglance-value" style="margin-bottom: 0px;">Radiant</div></div></div></div><div class="zsg-lg-1-3 zsg-md-1-2" style="display: inline-block; letter-spacing: normal; word-spacing: normal; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px; width: 164.328px;"><div class="hdp-fact-ataglance-container zsg-media" style="zoom: 1; padding: 0px 10px 15px 0px;"><div class="zsg-media-img" style="float: left; margin-right: 15px;"><span class="hdp-fact-ataglance-icon zsg-icon-snowflake" style="line-height: 1; vertical-align: middle; display: block; font-size: 28px; padding-top: 8px;"></span></div><div class="zsg-media-bd" style="display: table-cell; vertical-align: top; width: 10000px !important;"><p class="hdp-fact-ataglance-heading" style="margin-bottom: 0px; font-weight: 700;">Cooling</p><div class="hdp-fact-ataglance-value" style="margin-bottom: 0px;">Other</div></div></div></div><div class="zsg-lg-1-3 zsg-md-1-2" style="display: inline-block; letter-spacing: normal; word-spacing: normal; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px; width: 164.328px;"><div class="hdp-fact-ataglance-container zsg-media" style="zoom: 1; padding: 0px 10px 15px 0px;"><div class="zsg-media-img" style="float: left; margin-right: 15px;"><span class="hdp-fact-ataglance-icon zsg-icon-parking" style="line-height: 1; vertical-align: middle; display: block; font-size: 28px; padding-top: 8px;"></span></div><div class="zsg-media-bd" style="display: table-cell; vertical-align: top; width: 10000px !important;"><p class="hdp-fact-ataglance-heading" style="margin-bottom: 0px; font-weight: 700;">Parking</p><div class="hdp-fact-ataglance-value" style="margin-bottom: 0px;">5 spaces</div></div></div></div><div class="zsg-lg-1-3 zsg-md-1-2" style="display: inline-block; letter-spacing: normal; word-spacing: normal; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px; width: 164.328px;"><div class="hdp-fact-ataglance-container zsg-media" style="zoom: 1; padding: 0px 10px 15px 0px;"><div class="zsg-media-img" style="float: left; margin-right: 15px;"><span class="hdp-fact-ataglance-icon zsg-icon-lot" style="line-height: 1; vertical-align: middle; display: block; font-size: 28px; padding-top: 8px;"></span></div><div class="zsg-media-bd" style="display: table-cell; vertical-align: top; width: 10000px !important;"><p class="hdp-fact-ataglance-heading" style="margin-bottom: 0px; font-weight: 700;">Lot</p><div class="hdp-fact-ataglance-value" style="margin-bottom: 0px;">12 acres</div></div></div></div><div class="zsg-lg-1-3 zsg-md-1-2" style="display: inline-block; letter-spacing: normal; word-spacing: normal; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px; width: 164.328px;"><div class="hdp-fact-ataglance-container zsg-media" style="zoom: 1; padding: 0px 10px 15px 0px;"><div class="zsg-media-img" style="float: left; margin-right: 15px;"><span class="hdp-fact-ataglance-icon zsg-icon-days-on" style="line-height: 1; vertical-align: middle; display: block; font-size: 28px; padding-top: 8px;"></span></div><div class="zsg-media-bd" style="display: table-cell; vertical-align: top; width: 10000px !important;"><p class="hdp-fact-ataglance-heading" style="margin-bottom: 0px; font-weight: 700;">Days on Zillow</p><div class="hdp-fact-ataglance-value" style="margin-bottom: 0px;">36 Days</div></div></div></div><div class="zsg-lg-1-3 zsg-md-1-2" style="display: inline-block; letter-spacing: normal; word-spacing: normal; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px; width: 164.328px;"><div class="hdp-fact-ataglance-container zsg-media" style="zoom: 1; padding: 0px 10px 15px 0px;"><div class="zsg-media-img" style="float: left; margin-right: 15px;"><span class="hdp-fact-ataglance-icon zsg-icon-price-sqft" style="line-height: 1; vertical-align: middle; display: block; font-size: 28px; padding-top: 8px;"></span></div><div class="zsg-media-bd" style="display: table-cell; vertical-align: top; width: 10000px !important;"><p class="hdp-fact-ataglance-heading" style="margin-bottom: 0px; font-weight: 700;">Price/sqft</p><div class="hdp-fact-ataglance-value" style="margin-bottom: 0px;">$3,566</div></div></div></div><div class="zsg-lg-1-3 zsg-md-1-2" style="display: inline-block; letter-spacing: normal; word-spacing: normal; vertical-align: top; text-rendering: auto; font-family: Gotham, gotham, Verdana, sans-serif; padding: 0px; width: 164.328px;"><div class="hdp-fact-ataglance-container zsg-media" style="zoom: 1; padding: 0px 10px 15px 0px;"><div class="zsg-media-img" style="float: left; margin-right: 15px;"><span class="hdp-fact-ataglance-icon zsg-icon-user-saves" style="line-height: 1; vertical-align: middle; display: block; font-size: 28px; padding-top: 8px;"></span></div><div class="zsg-media-bd" style="display: table-cell; vertical-align: top; width: 10000px !important;"><p class="hdp-fact-ataglance-heading" style="margin-bottom: 0px; font-weight: 700;">Saves</p><div class="hdp-fact-ataglance-value" style="margin-bottom: 0px;">64</div></div></div></div></div><div class="z-moreless-content hdp-fact-moreless-content" id="yui_3_18_1_3_1506107368089_2546" style="position: relative; margin-bottom: 20px;"><h4 class="hdp-fact-category-heading" style="margin: 0px 0px 10px; color: rgb(68, 68, 68); font-size: 13px; line-height: 1.5; text-transform: uppercase; border-top: 1px solid rgb(221, 221, 221); padding-top: 15px;">INTERIOR FEATURES</h4><div class="hdp-fact-container-columns" style="column-count: 2; column-gap: 30px;"><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Bedrooms</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Beds:&nbsp;</span><span class="hdp-fact-value">4</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Bathrooms</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Baths:&nbsp;</span><span class="hdp-fact-value">4 full, 1 half</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Other Rooms</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Features:&nbsp;</span><span class="hdp-fact-value">Workshop</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div id="factsFeaturesTelecomAd" style="height: 0px; overflow: hidden;"><div style="padding-bottom: 15px;"></div></div><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Heating and Cooling</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Heating:&nbsp;</span><span class="hdp-fact-value">Radiant</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Heating:&nbsp;</span><span class="hdp-fact-value">None</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Cooling:&nbsp;</span><span class="hdp-fact-value">Other</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Flooring</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Floor size:&nbsp;</span><span class="hdp-fact-value">5,440 sqft</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Flooring:&nbsp;</span><span class="hdp-fact-value">Concrete</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Other Interior Features</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-value">Fireplace</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Room count:&nbsp;</span><span class="hdp-fact-value">14</span></li></ul></div></div><h4 class="hdp-fact-category-heading" style="margin: 0px 0px 10px; color: rgb(68, 68, 68); font-size: 13px; line-height: 1.5; text-transform: uppercase; border-top: 1px solid rgb(221, 221, 221); padding-top: 15px;">SPACES AND AMENITIES</h4><div class="hdp-fact-container-columns" style="column-count: 2; column-gap: 30px;"><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Spaces</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-value">Barbecue Area</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-value">Hot Tub/Spa</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-value">Pool</span></li></ul></div></div><h4 class="hdp-fact-category-heading" style="margin: 0px 0px 10px; color: rgb(68, 68, 68); font-size: 13px; line-height: 1.5; text-transform: uppercase; border-top: 1px solid rgb(221, 221, 221); padding-top: 15px;">CONSTRUCTION</h4><div class="hdp-fact-container-columns" style="column-count: 2; column-gap: 30px;"><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Type and Style</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Structure type:&nbsp;</span><span class="hdp-fact-value">Modern</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-value">Single Family</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Materials</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Exterior material:&nbsp;</span><span class="hdp-fact-value">Wood</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-value">Skylight</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Dates</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Last remodel year:&nbsp;</span><span class="hdp-fact-value">2002</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-value">Built in 2000</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Features:&nbsp;</span><span class="hdp-fact-value">11-20 Years Old</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Other Construction Features</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Stories:&nbsp;</span><span class="hdp-fact-value">1</span></li></ul></div></div><h4 class="hdp-fact-category-heading" style="margin: 0px 0px 10px; color: rgb(68, 68, 68); font-size: 13px; line-height: 1.5; text-transform: uppercase; border-top: 1px solid rgb(221, 221, 221); padding-top: 15px;">EXTERIOR FEATURES</h4><div class="hdp-fact-container-columns" id="yui_3_18_1_3_1506107368089_2545" style="column-count: 2; column-gap: 30px;"><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Patio</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-value">Porch</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Water</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-value">Pool</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Features:&nbsp;</span><span class="hdp-fact-value">City Water</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">View Type</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">View:&nbsp;</span><span class="hdp-fact-value">Mountain, Territorial</span></li></ul></div><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Lot</div><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Lot:&nbsp;</span><span class="hdp-fact-value">12 acres</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Features:&nbsp;</span><span class="hdp-fact-value">10-20 Acres</span></li></ul></div><div class="hdp-fact-container" id="yui_3_18_1_3_1506107368089_2544" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Other Exterior Features</div><ul class="zsg-sm-1-1 hdp-fact-list" id="yui_3_18_1_3_1506107368089_2543" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" id="yui_3_18_1_3_1506107368089_2542" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Parcel #:&nbsp;</span><span class="hdp-fact-value" id="yui_3_18_1_3_1506107368089_2541">17537037</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Features:&nbsp;</span><span class="hdp-fact-value">Guest House</span></li></ul></div></div><h4 class="hdp-fact-category-heading" style="margin: 0px 0px 10px; color: rgb(68, 68, 68); font-size: 13px; line-height: 1.5; text-transform: uppercase; border-top: 1px solid rgb(221, 221, 221); padding-top: 15px;">PARKING</h4><div class="hdp-fact-container-columns" id="yui_3_18_1_3_1506107368089_2553" style="column-count: 2; column-gap: 30px;"><div class="hdp-fact-container" id="yui_3_18_1_3_1506107368089_2552" style="padding: 0px 0px 5px; break-inside: avoid;"><ul class="zsg-sm-1-1 hdp-fact-list" id="yui_3_18_1_3_1506107368089_2551" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" id="yui_3_18_1_3_1506107368089_2550" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Parking:&nbsp;</span><span class="hdp-fact-value">Detached Garage, 5 spaces, 1428 sqft garage</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Features:&nbsp;</span><span class="hdp-fact-value">4 Car Garage</span></li></ul></div></div><h4 class="hdp-fact-category-heading" style="margin: 0px 0px 10px; color: rgb(68, 68, 68); font-size: 13px; line-height: 1.5; text-transform: uppercase; border-top: 1px solid rgb(221, 221, 221); padding-top: 15px;">UTILITIES</h4><div class="hdp-fact-container-columns" id="yui_3_18_1_3_1506107368089_2672" style="column-count: 2; column-gap: 30px;"><div class="hdp-fact-container" style="padding: 0px 0px 5px; break-inside: avoid;"><ul class="zsg-sm-1-1 hdp-fact-list" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-value">Sprinkler System</span></li><li class="" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">Features:&nbsp;</span><span class="hdp-fact-value">City</span></li></ul></div><div class="hdp-fact-container" id="yui_3_18_1_3_1506107368089_2671" style="padding: 0px 0px 5px; break-inside: avoid;"><div class="hdp-fact-category" style="font-weight: 700; margin-bottom: 5px;">Green Energy</div><ul class="zsg-sm-1-1 hdp-fact-list" id="yui_3_18_1_3_1506107368089_2670" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" id="yui_3_18_1_3_1506107368089_2669" style="padding-bottom: 5px;"><span class="hdp-fact-value">Great solar potential<br>Sun Number™:&nbsp;87</span><span class="zsg-tooltip-launch zsg-icon-circle-question" data-target-id="sun-score-tooltip" style="line-height: 1; vertical-align: middle; cursor: pointer; color: rgb(153, 153, 153); margin-left: 5px;"></span></li></ul></div></div><h4 class="hdp-fact-category-heading" style="margin: 0px 0px 10px; color: rgb(68, 68, 68); font-size: 13px; line-height: 1.5; text-transform: uppercase; border-top: 1px solid rgb(221, 221, 221); padding-top: 15px;">SOURCES</h4><div class="hdp-fact-container-columns" id="yui_3_18_1_3_1506107368089_2666" style="column-count: 2; column-gap: 30px;"><div class="hdp-fact-container" id="yui_3_18_1_3_1506107368089_2665" style="padding: 0px 0px 5px; break-inside: avoid;"><ul class="zsg-sm-1-1 hdp-fact-list" id="yui_3_18_1_3_1506107368089_2664" style="margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-bottom: 5px; display: inline-block; word-spacing: normal; vertical-align: top; text-rendering: auto; width: 231.5px;"><li class="" id="yui_3_18_1_3_1506107368089_2663" style="padding-bottom: 5px;"><span class="hdp-fact-name" style="color: rgb(153, 153, 153);">MLS #:&nbsp;</span><span class="hdp-fact-value" id="yui_3_18_1_3_1506107368089_2662">ML81674408</span></li><li class="" id="yui_3_18_1_3_1506107368089_2673" style="padding-bottom: 5px;"><span class="hdp-fact-value"><a href="http://www.sothebysrealty.com/id/rxh64s" title="Today Sotheby''s International Realty" id="listing-website-link" class="listing-website-link external track-ga-event truncated-link" target="_blank" data-ga-category="Homes" data-ga-action="Broker Click" data-ga-label="ListingWebsiteLinkTO, zpid: 19527625, bid: 9457" style="background-image: initial; background-position: 0px 0px; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial; cursor: pointer; color: rgb(100, 0, 150);">Today Sotheby''s International Realt...</a></span></li></ul></div></div></div></div></div></section>', N'12950 Robleda Road, Los Altos Hills, CA, United States', N'Los Altos Hills', NULL, N'94022', 37.368638, -122.127608, NULL, NULL, N'U679844771', CAST(0x0000A7F600DE6EF2 AS DateTime), NULL, 1, N'12950 Robleda Rd, Los Altos Hills, CA ', N'False', N'False', N'ML81674408', CAST(1.24 AS Decimal(18, 2)), N'UN438609345', 1955, NULL, NULL, NULL)
INSERT [dbo].[Property_tbl] ([PropertyId], [PropertyFor], [PropertyTypeId], [FrontImage], [Price], [PriceUnit], [Area], [AreaUnit], [PAgeId], [Description], [Address], [City], [State], [PostCode], [Latitude], [Longitude], [Video], [Contact], [CreatedBy], [CreatedOn], [FurnishedStatus], [Property_Status], [Property_Title], [Featured], [IsSold], [MLSNumber], [LOTArea], [LOTAreaUnit], [YearBuilt], [DateOnMarker], [PerAreaPrice], [PerAreaUnit]) VALUES (N'P355162091', N'COMMERCIAL FOR SALE', N'PT128416961', N'06112017174552057_118.jpg', CAST(54632.00 AS Decimal(18, 2)), NULL, CAST(6464.25 AS Decimal(18, 2)), N'UN311555433', NULL, N'<p>Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text Demo text&nbsp;</p>', N'Naipalia Trace, Penal, Penal-Debe Regional Corporation, Trinidad and Tobago', N'Penal', NULL, N'987654', 10.1659541, -61.434270599999991, NULL, NULL, N'U679844771', CAST(0x0000A8230124A432 AS DateTime), NULL, 1, N'Test Commercial property', N'True', N'False', N'4564654', CAST(52.36 AS Decimal(18, 2)), N'UN311555433', 2016, NULL, NULL, NULL)
INSERT [dbo].[Property_tbl] ([PropertyId], [PropertyFor], [PropertyTypeId], [FrontImage], [Price], [PriceUnit], [Area], [AreaUnit], [PAgeId], [Description], [Address], [City], [State], [PostCode], [Latitude], [Longitude], [Video], [Contact], [CreatedBy], [CreatedOn], [FurnishedStatus], [Property_Status], [Property_Title], [Featured], [IsSold], [MLSNumber], [LOTArea], [LOTAreaUnit], [YearBuilt], [DateOnMarker], [PerAreaPrice], [PerAreaUnit]) VALUES (N'P375654081', N'SALE', N'10005', N'', CAST(654654.00 AS Decimal(18, 2)), NULL, CAST(152089.56 AS Decimal(18, 2)), N'UN311555433', NULL, N'<p>Demo text</p>', N'Asansol Jn, Drysdale Road, Railpar, Asansol, West Bengal, India', N'Asansol', NULL, N'713301', 23.6911108, 86.975235, NULL, NULL, N'U679844771', CAST(0x0000A7FA01023CA9 AS DateTime), NULL, 1, N'Test Property', N'True', N'False', N'4654654', CAST(12.55 AS Decimal(18, 2)), N'UN438609345', 2016, NULL, NULL, NULL)
INSERT [dbo].[Property_tbl] ([PropertyId], [PropertyFor], [PropertyTypeId], [FrontImage], [Price], [PriceUnit], [Area], [AreaUnit], [PAgeId], [Description], [Address], [City], [State], [PostCode], [Latitude], [Longitude], [Video], [Contact], [CreatedBy], [CreatedOn], [FurnishedStatus], [Property_Status], [Property_Title], [Featured], [IsSold], [MLSNumber], [LOTArea], [LOTAreaUnit], [YearBuilt], [DateOnMarker], [PerAreaPrice], [PerAreaUnit]) VALUES (N'P667672818', N'SALE', N'10002', N'20092017021102112_102.jpg', CAST(250000.00 AS Decimal(18, 2)), NULL, CAST(8000.00 AS Decimal(18, 2)), N'UN311555433', NULL, N'<p>JOHN PROPERTY # 1&nbsp;</p><p><br></p><p>TEST LINE 2&nbsp;</p><p><br></p><p>TEST LINE 3</p>', N'1 Georgia Way, San Leandro, CA, United States', N'San Leandro', NULL, N'94577', 37.7322416, -122.1614119, NULL, NULL, N'U679844771', CAST(0x0000A7F40023FD78 AS DateTime), NULL, 1, N'Stark Homes', N'True', N'False', N'70000', CAST(10000.00 AS Decimal(18, 2)), N'UN311555433', 2017, NULL, NULL, NULL)
INSERT [dbo].[Property_video] ([VideoId], [PropertyId], [Video_Title], [File_Type], [Video], [Video_Entrydate]) VALUES (N'PV013374312', N'P613563970', N'Test Prop Youtube', N'Youtube', N'-qdFcxHUWwI', CAST(0x0000A7A701591BEB AS DateTime))
INSERT [dbo].[Property_video] ([VideoId], [PropertyId], [Video_Title], [File_Type], [Video], [Video_Entrydate]) VALUES (N'PV646287093', N'P613563970', N'Test Prop Video', N'System', N'05072017205452480_68.mp4', CAST(0x0000A7A70158A964 AS DateTime))
INSERT [dbo].[Property_video] ([VideoId], [PropertyId], [Video_Title], [File_Type], [Video], [Video_Entrydate]) VALUES (N'PV693256088', N'P908594713', N'Test Prop Video', N'System', N'05072017205425558_67.mp4', CAST(0x0000A7A7015889D9 AS DateTime))
INSERT [dbo].[Property_video] ([VideoId], [PropertyId], [Video_Title], [File_Type], [Video], [Video_Entrydate]) VALUES (N'PV899089667', N'P734344605', N'Test Prop Video', N'System', N'06072017062523653_68.mp4', CAST(0x0000A7A80069DA06 AS DateTime))
SET IDENTITY_INSERT [dbo].[PropertyAgeMaster_tbl] ON 

INSERT [dbo].[PropertyAgeMaster_tbl] ([PAgeId], [PropertyAge]) VALUES (2, N'10 -15 years')
INSERT [dbo].[PropertyAgeMaster_tbl] ([PAgeId], [PropertyAge]) VALUES (3, N'10-20 Years')
INSERT [dbo].[PropertyAgeMaster_tbl] ([PAgeId], [PropertyAge]) VALUES (4, N'Very Old')
SET IDENTITY_INSERT [dbo].[PropertyAgeMaster_tbl] OFF
SET IDENTITY_INSERT [dbo].[PropertyCharacteristics] ON 

INSERT [dbo].[PropertyCharacteristics] ([CharId], [Characteristic]) VALUES (1, N'Onsite Facilities')
INSERT [dbo].[PropertyCharacteristics] ([CharId], [Characteristic]) VALUES (2, N'Kitchen / Diner ')
INSERT [dbo].[PropertyCharacteristics] ([CharId], [Characteristic]) VALUES (4, N'Outside Space')
SET IDENTITY_INSERT [dbo].[PropertyCharacteristics] OFF
SET IDENTITY_INSERT [dbo].[PropertyType_Pfor_mapping] ON 

INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (20, N'PT801730233', N'BUY')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (21, N'PT801730233', N'SALE')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (22, N'PT801730233', N'RENT')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (23, N'PT801730233', N'COMMERCIAL')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (24, N'PT472229297', N'BUY')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (25, N'PT472229297', N'SALE')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (26, N'PT472229297', N'RENT')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (27, N'PT472229297', N'COMMERCIAL')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (28, N'PT439016191', N'BUY')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (29, N'PT439016191', N'SALE')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (30, N'PT439016191', N'RENT')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (31, N'PT439016191', N'COMMERCIAL')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (32, N'PT387871155', N'BUY')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (33, N'PT387871155', N'SALE')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (34, N'PT387871155', N'RENT')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (35, N'PT387871155', N'COMMERCIAL')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (36, N'PT128416961', N'BUY')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (37, N'PT128416961', N'SALE')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (38, N'PT128416961', N'RENT')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (39, N'PT128416961', N'COMMERCIAL')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (40, N'10007', N'BUY')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (41, N'10007', N'SALE')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (42, N'10007', N'RENT')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (43, N'10006', N'BUY')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (44, N'10006', N'SALE')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (45, N'10006', N'RENT')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (46, N'10005', N'BUY')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (47, N'10005', N'SALE')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (48, N'10005', N'RENT')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (49, N'10004', N'BUY')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (50, N'10004', N'SALE')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (51, N'10004', N'RENT')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (52, N'10002', N'BUY')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (53, N'10002', N'SALE')
INSERT [dbo].[PropertyType_Pfor_mapping] ([Id], [PropertyTypeId], [PropertyFor]) VALUES (54, N'10002', N'RENT')
SET IDENTITY_INSERT [dbo].[PropertyType_Pfor_mapping] OFF
INSERT [dbo].[PropertyType_tbl] ([PropertyTypeId], [PropertyType], [PropertyTyp_Image], [RentPossible], [IsActive], [PropertyTypeCode]) VALUES (N'10002', N'APARTMENT', N'19092017140832378_16.gif', NULL, 1, N'AP')
INSERT [dbo].[PropertyType_tbl] ([PropertyTypeId], [PropertyType], [PropertyTyp_Image], [RentPossible], [IsActive], [PropertyTypeCode]) VALUES (N'10004', N'HOUSE', N'19092017140646393_16.jpg', NULL, 1, N'DE')
INSERT [dbo].[PropertyType_tbl] ([PropertyTypeId], [PropertyType], [PropertyTyp_Image], [RentPossible], [IsActive], [PropertyTypeCode]) VALUES (N'10005', N'TOWNHOUSE', N'19092017140513111_16.jpg', NULL, 1, N'TH')
INSERT [dbo].[PropertyType_tbl] ([PropertyTypeId], [PropertyType], [PropertyTyp_Image], [RentPossible], [IsActive], [PropertyTypeCode]) VALUES (N'10006', N'CONDO', N'14112017094154232_15.jpg', NULL, 1, N'CO')
INSERT [dbo].[PropertyType_tbl] ([PropertyTypeId], [PropertyType], [PropertyTyp_Image], [RentPossible], [IsActive], [PropertyTypeCode]) VALUES (N'10007', N'MANUFACTURED HOMES', N'14112017094143971_14.jpg', NULL, 1, N'MF')
INSERT [dbo].[PropertyType_tbl] ([PropertyTypeId], [PropertyType], [PropertyTyp_Image], [RentPossible], [IsActive], [PropertyTypeCode]) VALUES (N'PT128416961', N'LAND / LOT', N'14112017094131677_13.jpg', NULL, NULL, N'LD')
INSERT [dbo].[PropertyType_tbl] ([PropertyTypeId], [PropertyType], [PropertyTyp_Image], [RentPossible], [IsActive], [PropertyTypeCode]) VALUES (N'PT387871155', N'OFFICE', N'14112017093742505_12.jpg', NULL, NULL, N'OF')
INSERT [dbo].[PropertyType_tbl] ([PropertyTypeId], [PropertyType], [PropertyTyp_Image], [RentPossible], [IsActive], [PropertyTypeCode]) VALUES (N'PT439016191', N'WAREHOUSE', N'14112017093731365_11.jpg', NULL, NULL, N'WH')
INSERT [dbo].[PropertyType_tbl] ([PropertyTypeId], [PropertyType], [PropertyTyp_Image], [RentPossible], [IsActive], [PropertyTypeCode]) VALUES (N'PT472229297', N'RETAIL', N'14112017093720321_10.jpg', NULL, NULL, N'RE')
INSERT [dbo].[PropertyType_tbl] ([PropertyTypeId], [PropertyType], [PropertyTyp_Image], [RentPossible], [IsActive], [PropertyTypeCode]) VALUES (N'PT801730233', N'INDUSTRIAL', N'14112017093702027_9.jpg', NULL, NULL, N'ID')
SET IDENTITY_INSERT [dbo].[ProprtyType_Feature_Mapping] ON 

INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10007, N'F055491247', N'10006')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10008, N'F338342725', N'10006')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10009, N'F349971975', N'10006')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10010, N'F417412669', N'10006')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10011, N'F677138400', N'10006')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10012, N'F055491247', N'10005')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10013, N'F338342725', N'10005')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10014, N'F349971975', N'10005')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10015, N'F417412669', N'10005')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10016, N'F677138400', N'10005')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10057, N'F055491247', N'10003')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10058, N'F338342725', N'10003')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10059, N'F349971975', N'10003')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10060, N'F417412669', N'10003')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10061, N'F677138400', N'10003')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10067, N'F055491247', N'PT128416961')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10068, N'F055491247', N'PT439016191')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10069, N'F055491247', N'10007')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10070, N'F338342725', N'10007')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10071, N'F349971975', N'10007')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10072, N'F417412669', N'10007')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10073, N'F677138400', N'10007')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10074, N'F055491247', N'10004')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10075, N'F338342725', N'10004')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10076, N'F349971975', N'10004')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10077, N'F417412669', N'10004')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10078, N'F677138400', N'10004')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10089, N'F055491247', N'10002')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10090, N'F338342725', N'10002')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10091, N'F349971975', N'10002')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10092, N'F417412669', N'10002')
INSERT [dbo].[ProprtyType_Feature_Mapping] ([Feature_Ptype_Mapping_Id], [FeatureId], [PropertyTypeId]) VALUES (10093, N'F677138400', N'10002')
SET IDENTITY_INSERT [dbo].[ProprtyType_Feature_Mapping] OFF
SET IDENTITY_INSERT [dbo].[RecentSearchTbl] ON 

INSERT [dbo].[RecentSearchTbl] ([SrlNo], [UniqueId], [SearchId], [SearchType], [SearchName]) VALUES (214, N'f2e531a070da4ab3a6a6e26eb1893983', N'1', N'FEATURE', N'Needs Modernisation (1)')
INSERT [dbo].[RecentSearchTbl] ([SrlNo], [UniqueId], [SearchId], [SearchType], [SearchName]) VALUES (215, N'f2e531a070da4ab3a6a6e26eb1893983', N'2', N'CHARACTER', N'Kitchen / Diner  (1)')
INSERT [dbo].[RecentSearchTbl] ([SrlNo], [UniqueId], [SearchId], [SearchType], [SearchName]) VALUES (216, N'f2e531a070da4ab3a6a6e26eb1893983', N'1', N'AGE', N'Modern (1)')
SET IDENTITY_INSERT [dbo].[RecentSearchTbl] OFF
SET IDENTITY_INSERT [dbo].[Search_tbl] ON 

INSERT [dbo].[Search_tbl] ([SrlNo], [uniqueId], [Location], [MinPrice], [MaxPrice], [MinBed]) VALUES (8, N'db1fbc95c65a4566a9e12dbbdd02bcb0', N'', 0, 0, 0)
SET IDENTITY_INSERT [dbo].[Search_tbl] OFF
SET IDENTITY_INSERT [dbo].[Slide] ON 

INSERT [dbo].[Slide] ([id], [Slide_Name], [Title], [Image]) VALUES (2, N'Slide 1', N'Amazing post with all the goodies drf', N'587965381.jpg')
INSERT [dbo].[Slide] ([id], [Slide_Name], [Title], [Image]) VALUES (3, N'Banner 2', N'nice images ', N'398409039.jpg')
SET IDENTITY_INSERT [dbo].[Slide] OFF
SET IDENTITY_INSERT [dbo].[Social] ON 

INSERT [dbo].[Social] ([Id], [Facebook], [Twitter], [Instagram], [Googleplus], [Youtube], [Linkedin]) VALUES (1, N'https://www.facebook.com/login.php', N'https://twitter.com/', N'https://www.instagram.com/', N'https://plus.google.com/collections/featured', N'https://www.youtube.com/', N'https://www.linkedin.com/')
SET IDENTITY_INSERT [dbo].[Social] OFF
SET IDENTITY_INSERT [dbo].[SociallinkMapping_tbl] ON 

INSERT [dbo].[SociallinkMapping_tbl] ([Id], [SMID], [SocialId], [UserId], [Social_link], [Entrydate]) VALUES (5, N'SL351816682', 1, N'U831603621', N'https://www.facebook.com/', CAST(0x0000A83D00A3AB52 AS DateTime))
INSERT [dbo].[SociallinkMapping_tbl] ([Id], [SMID], [SocialId], [UserId], [Social_link], [Entrydate]) VALUES (7, N'SL456709854', 3, N'U831603621', N'https://www.instagram.com/', CAST(0x0000A83D00A3F177 AS DateTime))
INSERT [dbo].[SociallinkMapping_tbl] ([Id], [SMID], [SocialId], [UserId], [Social_link], [Entrydate]) VALUES (8, N'SL949155731', 4, N'U831603621', N'https://in.linkedin.com/', CAST(0x0000A83D00A40E61 AS DateTime))
INSERT [dbo].[SociallinkMapping_tbl] ([Id], [SMID], [SocialId], [UserId], [Social_link], [Entrydate]) VALUES (6, N'SL966107729', 2, N'U831603621', N'https://twitter.com/', CAST(0x0000A83D00A3D18E AS DateTime))
SET IDENTITY_INSERT [dbo].[SociallinkMapping_tbl] OFF
SET IDENTITY_INSERT [dbo].[SociallinkMaster_tbl] ON 

INSERT [dbo].[SociallinkMaster_tbl] ([SocialId], [Social_Site], [Social_Icon]) VALUES (1, N'Facebook', N'icons8-facebook-40.png')
INSERT [dbo].[SociallinkMaster_tbl] ([SocialId], [Social_Site], [Social_Icon]) VALUES (2, N'Twitter', N'icons8-twitter-40.png')
INSERT [dbo].[SociallinkMaster_tbl] ([SocialId], [Social_Site], [Social_Icon]) VALUES (3, N'Instragram', N'icons8-instagram-40.png')
INSERT [dbo].[SociallinkMaster_tbl] ([SocialId], [Social_Site], [Social_Icon]) VALUES (4, N'Linkedin', N'icons8-linkedin-40.png')
INSERT [dbo].[SociallinkMaster_tbl] ([SocialId], [Social_Site], [Social_Icon]) VALUES (5, N'Googleplus', N'icons8-google-plus-40.png')
INSERT [dbo].[SociallinkMaster_tbl] ([SocialId], [Social_Site], [Social_Icon]) VALUES (6, N'Youtube', N'icons8-youtube-40.png')
INSERT [dbo].[SociallinkMaster_tbl] ([SocialId], [Social_Site], [Social_Icon]) VALUES (7, N'Whatsapp', N'icons8-whatsapp-40.png')
SET IDENTITY_INSERT [dbo].[SociallinkMaster_tbl] OFF
SET IDENTITY_INSERT [dbo].[StampDuty_tbl] ON 

INSERT [dbo].[StampDuty_tbl] ([Id], [AFrom], [ATo], [SRate], [SecondHrate]) VALUES (1, CAST(1.00 AS Decimal(18, 2)), CAST(125000.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(3.00 AS Decimal(18, 2)))
INSERT [dbo].[StampDuty_tbl] ([Id], [AFrom], [ATo], [SRate], [SecondHrate]) VALUES (2, CAST(125001.00 AS Decimal(18, 2)), CAST(250000.00 AS Decimal(18, 2)), CAST(2.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)))
INSERT [dbo].[StampDuty_tbl] ([Id], [AFrom], [ATo], [SRate], [SecondHrate]) VALUES (3, CAST(250001.00 AS Decimal(18, 2)), CAST(925000.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(8.00 AS Decimal(18, 2)))
INSERT [dbo].[StampDuty_tbl] ([Id], [AFrom], [ATo], [SRate], [SecondHrate]) VALUES (4, CAST(925001.00 AS Decimal(18, 2)), CAST(1500000.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), CAST(13.00 AS Decimal(18, 2)))
INSERT [dbo].[StampDuty_tbl] ([Id], [AFrom], [ATo], [SRate], [SecondHrate]) VALUES (7, CAST(1500001.00 AS Decimal(18, 2)), CAST(10000000000000.00 AS Decimal(18, 2)), CAST(12.00 AS Decimal(18, 2)), CAST(15.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[StampDuty_tbl] OFF
SET IDENTITY_INSERT [dbo].[Subscription_tbl] ON 

INSERT [dbo].[Subscription_tbl] ([Id], [SubscripId], [Email], [IsSuscribed], [Entrydate]) VALUES (22, N'S102071984', N'apx510@gmail.com', 0, CAST(0x0000A7F4017658F4 AS DateTime))
INSERT [dbo].[Subscription_tbl] ([Id], [SubscripId], [Email], [IsSuscribed], [Entrydate]) VALUES (23, N'S460275823', N'asdasd@gmail.com', 0, CAST(0x0000A7F90162AED6 AS DateTime))
INSERT [dbo].[Subscription_tbl] ([Id], [SubscripId], [Email], [IsSuscribed], [Entrydate]) VALUES (24, N'S748997238', N'demopartner@gmail.com', 0, CAST(0x0000A7F901657CB3 AS DateTime))
INSERT [dbo].[Subscription_tbl] ([Id], [SubscripId], [Email], [IsSuscribed], [Entrydate]) VALUES (25, N'S605935660', N'web1112151@goigi.asia', 0, CAST(0x0000A84400EBA3D7 AS DateTime))
SET IDENTITY_INSERT [dbo].[Subscription_tbl] OFF
INSERT [dbo].[TaxHistory_tbl] ([TaxId], [Year], [PropertyTax], [PTax_Changes], [TaxAssessmnt], [TaxAssessmnt_Changes], [PropertyId], [Entry_Date]) VALUES (N'T054829602', 2018, CAST(800.000 AS Decimal(18, 3)), CAST(70 AS Decimal(18, 0)), CAST(440.000 AS Decimal(18, 3)), CAST(20 AS Decimal(18, 0)), N'P613563970', CAST(0x0000A78D00674D80 AS DateTime))
INSERT [dbo].[TaxHistory_tbl] ([TaxId], [Year], [PropertyTax], [PTax_Changes], [TaxAssessmnt], [TaxAssessmnt_Changes], [PropertyId], [Entry_Date]) VALUES (N'T122900002', 2015, CAST(780.000 AS Decimal(18, 3)), CAST(90 AS Decimal(18, 0)), CAST(600.000 AS Decimal(18, 3)), CAST(20 AS Decimal(18, 0)), N'P258950078', CAST(0x0000A78D006B9232 AS DateTime))
INSERT [dbo].[TaxHistory_tbl] ([TaxId], [Year], [PropertyTax], [PTax_Changes], [TaxAssessmnt], [TaxAssessmnt_Changes], [PropertyId], [Entry_Date]) VALUES (N'T724048967', 2016, CAST(700.000 AS Decimal(18, 3)), CAST(60 AS Decimal(18, 0)), CAST(900.000 AS Decimal(18, 3)), CAST(30 AS Decimal(18, 0)), N'P734344605', CAST(0x0000A78D00672307 AS DateTime))
INSERT [dbo].[TaxHistory_tbl] ([TaxId], [Year], [PropertyTax], [PTax_Changes], [TaxAssessmnt], [TaxAssessmnt_Changes], [PropertyId], [Entry_Date]) VALUES (N'T950714426', 2016, CAST(600.000 AS Decimal(18, 3)), CAST(50 AS Decimal(18, 0)), CAST(500.000 AS Decimal(18, 3)), CAST(50 AS Decimal(18, 0)), N'P098421340', CAST(0x0000A78D00C42909 AS DateTime))
SET IDENTITY_INSERT [dbo].[tblCMS] ON 

INSERT [dbo].[tblCMS] ([Id], [Meta_Tag], [Meta_Description], [Page_Name], [Page_Title], [Page_Heading], [Section], [Page_Content]) VALUES (1, NULL, NULL, N'Home', N'  Home', N'Home', N'Sell Property', N'<p>​</p>

<p class="pcolor">The real estate agents can also create a profile and upload their property listings into the website</p>
')
INSERT [dbo].[tblCMS] ([Id], [Meta_Tag], [Meta_Description], [Page_Name], [Page_Title], [Page_Heading], [Section], [Page_Content]) VALUES (2, NULL, NULL, N'Home', N'  Home', N'Home', N'Expert Agents', N'<p>​</p>

<p class="pcolor">The real estate agents can also create a profile and upload their property listings into the website&nbsp;</p>
')
INSERT [dbo].[tblCMS] ([Id], [Meta_Tag], [Meta_Description], [Page_Name], [Page_Title], [Page_Heading], [Section], [Page_Content]) VALUES (3, NULL, NULL, N'Home', N'Home', N'Home', N'Daily Listings', N'<p>​</p>

<p class="pcolor">The real estate agents can also create a profile and upload their property listings into the website</p>
')
INSERT [dbo].[tblCMS] ([Id], [Meta_Tag], [Meta_Description], [Page_Name], [Page_Title], [Page_Heading], [Section], [Page_Content]) VALUES (4, NULL, NULL, N'Testimonial', N'Testimonial', N'Testimonial', N'Testimonial', N'<p>​</p>

<p>The real estate agents can also create a profile and upload their property listings into the website</p>
')
INSERT [dbo].[tblCMS] ([Id], [Meta_Tag], [Meta_Description], [Page_Name], [Page_Title], [Page_Heading], [Section], [Page_Content]) VALUES (5, NULL, NULL, N'Home', N'Home', N'Home', N'Recently Added', N'<p>The real estate agents can also create a profile and upload their property listings into the website</p>
')
INSERT [dbo].[tblCMS] ([Id], [Meta_Tag], [Meta_Description], [Page_Name], [Page_Title], [Page_Heading], [Section], [Page_Content]) VALUES (1002, NULL, NULL, N'TERMS', N'TERMS & CONDITION', N'TERMS', N'TERMS', N'<p>Terms &amp; Condition&nbsp;</p>

<p>Loream eption</p>
')
INSERT [dbo].[tblCMS] ([Id], [Meta_Tag], [Meta_Description], [Page_Name], [Page_Title], [Page_Heading], [Section], [Page_Content]) VALUES (1003, NULL, NULL, N'POLICY', N'PRIVACY POLICY', N'POLICY', N'POLICY', N'<p>Privacy policy</p>

<p>Privacy policy</p>
')
SET IDENTITY_INSERT [dbo].[tblCMS] OFF
INSERT [dbo].[Testimonial] ([Tid], [Name], [Designation], [Comment], [Photo], [Status], [Entry_Date]) VALUES (N'T204626914', N'SARAH JENKS', N'DREAM HOME', N'KHU PHO has help us find our DREAM HOME without the headache. Thank you!', N'19092017153809570_2.jpg', N'TRUE', CAST(0x0000A7F30101AC74 AS DateTime))
INSERT [dbo].[Testimonial] ([Tid], [Name], [Designation], [Comment], [Photo], [Status], [Entry_Date]) VALUES (N'T915273621', N'JOHN JOHNSON', N'FAMILY HOME', N'KHU PHO made it possible for what I thought would be impossible to find. A home that fit my growing family and room to grow. Thank you very much KHU PHO!', N'19092017154057743_3.jpg', N'TRUE', CAST(0x0000A7F301027186 AS DateTime))
INSERT [dbo].[User_Type] ([Uid], [UserTypeName], [DisplayName]) VALUES (1, N'BUYER', N'Buyer/Owner')
INSERT [dbo].[User_Type] ([Uid], [UserTypeName], [DisplayName]) VALUES (2, N'AGENT', N'Agent')
SET IDENTITY_INSERT [dbo].[ValuationRequest_tbl] ON 

INSERT [dbo].[ValuationRequest_tbl] ([SrlNo], [Title], [Name], [PhoneNo], [EmailId], [Address], [PostCode], [Details], [RequestFor]) VALUES (1, N'Mr', N'Name', N'9876543210', N'john@gmail.com', N'xyz', N'AA100', N'Detail', N'SALE')
INSERT [dbo].[ValuationRequest_tbl] ([SrlNo], [Title], [Name], [PhoneNo], [EmailId], [Address], [PostCode], [Details], [RequestFor]) VALUES (2, N'Miss', N'XYZ', N'123456789', N'xyz@xyz.comn', N'Vanezuela,C-5 Apaertment near Parking Slot, London, UK', N'025036', N'JUST FILL IN YOUR DETAILS BELOW AND WE’LL CALL YOU TO ARRANGE YOUR VALUATION', N'SALE')
INSERT [dbo].[ValuationRequest_tbl] ([SrlNo], [Title], [Name], [PhoneNo], [EmailId], [Address], [PostCode], [Details], [RequestFor]) VALUES (3, N'Ms', N'Jenefer', N'142536987', N'j@gmail.com', N'abc', N'123456789', N'test test test', N'RENT')
SET IDENTITY_INSERT [dbo].[ValuationRequest_tbl] OFF
INSERT [dbo].[WeekDay_tbl] ([WeekDayName], [Week_Day]) VALUES (N'SUNDAY', 0)
INSERT [dbo].[WeekDay_tbl] ([WeekDayName], [Week_Day]) VALUES (N'MONDAY', 1)
INSERT [dbo].[WeekDay_tbl] ([WeekDayName], [Week_Day]) VALUES (N'TUESDAY', 2)
INSERT [dbo].[WeekDay_tbl] ([WeekDayName], [Week_Day]) VALUES (N'WEDNESDAY', 3)
INSERT [dbo].[WeekDay_tbl] ([WeekDayName], [Week_Day]) VALUES (N'THURSDAY', 4)
INSERT [dbo].[WeekDay_tbl] ([WeekDayName], [Week_Day]) VALUES (N'FRIDAY', 5)
INSERT [dbo].[WeekDay_tbl] ([WeekDayName], [Week_Day]) VALUES (N'SATURDAY', 6)
ALTER TABLE [dbo].[Login_Table] ADD  CONSTRAINT [DF_Login_Table_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[Message] ADD  CONSTRAINT [DF_Message_Is_Read]  DEFAULT ((0)) FOR [Is_Read]
GO
ALTER TABLE [dbo].[Message] ADD  CONSTRAINT [DF_Message_IsPublic]  DEFAULT ((1)) FOR [IsPublic]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Profile_Info"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 214
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 12
         End
         Begin Table = "Login_Table"
            Begin Extent = 
               Top = 6
               Left = 268
               Bottom = 178
               Right = 438
            End
            DisplayFlags = 280
            TopColumn = 5
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_ChatLoginProfile'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_ChatLoginProfile'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[4] 2[4] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ClassifiedAds_tbl"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 208
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "ClassifiedCategory"
            Begin Extent = 
               Top = 6
               Left = 271
               Bottom = 135
               Right = 441
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 17
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1650
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Classfied_Category'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Classfied_Category'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[30] 4[4] 2[4] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "AgentContact_tbl"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 204
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Property_tbl"
            Begin Extent = 
               Top = 6
               Left = 254
               Bottom = 191
               Right = 427
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Contact_Property'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Contact_Property'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[76] 4[12] 2[4] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "User_Type"
            Begin Extent = 
               Top = 13
               Left = 12
               Bottom = 219
               Right = 182
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Login_Table"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 280
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Profile_Info"
            Begin Extent = 
               Top = 11
               Left = 471
               Bottom = 370
               Right = 663
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Login_Profile'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Login_Profile'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[70] 4[21] 2[4] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "AreaUnit_tbl"
            Begin Extent = 
               Top = 0
               Left = 815
               Bottom = 129
               Right = 1011
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Property_tbl"
            Begin Extent = 
               Top = 0
               Left = 561
               Bottom = 456
               Right = 734
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Profile_Info"
            Begin Extent = 
               Top = 145
               Left = 320
               Bottom = 371
               Right = 512
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Login_Table"
            Begin Extent = 
               Top = 14
               Left = 99
               Bottom = 267
               Right = 269
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AreaUnit_tbl_1"
            Begin Extent = 
               Top = 151
               Left = 818
               Bottom = 280
               Right = 1014
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PropertyType_tbl"
            Begin Extent = 
               Top = 0
               Left = 330
               Bottom = 129
               Right = 522
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PropertyAgeMaster_tbl"
            Begin Extent = 
               Top = 301
               Left = 833
               Bottom = 396
               Right = 1003' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Propertydtl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Propertydtl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Propertydtl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[42] 4[10] 2[2] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SociallinkMaster_tbl"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 132
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SociallinkMapping_tbl"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 135
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 3060
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1665
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_sociallink_mapping'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_sociallink_mapping'
GO
