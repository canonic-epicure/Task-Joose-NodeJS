StartTest(function(t) {
    
	t.plan(1)
    
    var async0 = t.beginAsync()
    
    use('Task.Joose.NodeJS', function () {
        
        //======================================================================================================================================================================================================================================================
        t.diag('Sanity')
        
        t.ok(Task.Joose.NodeJS, "Task.Joose.NodeJS is here")
        
        t.endAsync(async0)
    })
})    