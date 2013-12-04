set ansi_warnings off
set nocount on

--unit test infrastructure
declare
	@testResult table (
		testId int identity(1,1) not null, 
		passed bit default 0 not null, 
		whenCondition varchar(500) not null, 
		thenCondition varchar(500) not null, 
		error nvarchar(2048) null
	)

declare
	@unitTestContext varchar(500) = '[context of unit tests]',
	@transaction varchar(20) = 'UnitTest',
	@whenCondition varchar(500),
	@thenCondition varchar(500),
	@passed bit
	
--test support data
declare
	
begin try

begin transaction @transaction

	select @whenCondition = '[pre-conditions]',
				 @thenCondition = '[post-conditions]';

	--arrange

	--act

	--assert final conditions
	set @passed = 0
	select @passed = IsCompleted from lmsUserCourseProgress where CourseGUID = @courseGuidA and UserGUID = @userGuid
	
	--log test result
	insert into @testResult (WhenCondition, ThenCondition, Passed) values(@whenCondition, @thenCondition, isnull(@passed, 0))
	
rollback transaction @transaction

end try
begin catch
	insert into @testResult (WhenCondition, ThenCondition, Error) values(
		@whenCondition,
		@thenCondition,
		error_message()
	)
	
	rollback transaction @transaction
end catch;

--table output
select
	*
from
	@testResult

--text output
print 'Unit Test Context:' + @unitTestContext

select
	'When: ' + WhenCondition + char(13) + 'Then: ' + ThenCondition + char(13) + 'Result: ' + case when Passed = 1 then 'Passed' else 'Failed' end
from
	@testResult
order by
	Passed asc, TestId asc

--xml attribute encoding output
select
	*
from
	@testResult
for xml raw('UnitTest'), root('UnitTests')

--xml element encoding output
select
	*
from
	@testResult
for xml path('UnitTest'), root('UnitTests')