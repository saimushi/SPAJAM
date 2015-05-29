var crudEnabled = false;
$(document).ready(function() {
	// ログインユーザーの名前を取得
	$.ajax({
		url: "api/me/user.json",
		dataType: "json",
		cache: false,
	}).done(function(json) {
		$("#username").text(json[0].name);
	});
	if(true != crudEnabled){
		// プロジェクトの一覧を取得
		$.ajax({
			url: "api/project.json",
			dataType: "json",
			cache: false,
		}).done(function(json) {
			var projectdombase = $("#projectlist .project").parent().html();
			var projectlist = "";
			for(var idx=0; idx < json.length; idx++){
				projectlist += projectdombase.replace("project name", json[idx]).replace("_project_", json[idx]).replace("class=\"project ", "class=\"project " + json[idx] + " ");
			}
			$("#projectlist").html(projectlist);
			// ページのメニューセレクティング
			var dom = $("ul.nav li a[href='./" + window.location.href.split('/').pop() + "']").parent("li");
			dom.attr("class", dom.attr("class") + " selected");
		});
	}
});
