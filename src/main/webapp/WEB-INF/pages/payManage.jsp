<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/common/Head.jsp"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<link class="uiTheme" rel="stylesheet" type="text/css" href="${basePath}jquery-easyui-1.3.3/themes/<%=themeName %>/easyui.css">
<link rel="stylesheet" type="text/css" href="${basePath}jquery-easyui-1.3.3/themes/icon.css">
<script type="text/javascript" src="${basePath}jquery-easyui-1.3.3/jquery.min.js"></script>
<script type="text/javascript" src="${basePath}jquery-easyui-1.3.3/jquery.easyui.min.js"></script>
<script type="text/javascript" src="${basePath}jquery-easyui-1.3.3/locale/easyui-lang-zh_CN.js"></script>
<script type="text/javascript" src="${basePath}jquery-easyui-1.3.3/jquery.cookie.js"></script>
<script type="text/javascript">
	var url;

	function searchPay() {
		var s_starttime = $("#s_starttime").datetimebox("getValue");
		var s_endtime = $("#s_endtime").datetimebox("getValue");
		if((s_starttime!="")&&(s_endtime!="")&&(s_starttime>s_endtime)){
			$.messager.alert("系统提示","起始时间不能大于截止时间！");
			return;
		}
		$("#dg").datagrid('load',{
			"payer" : $("#s_payer").val(),
			"tword" : $("#s_tword").val(),
			"dataid" : $("#s_dataid").combobox("getValue"),
			"starttime":s_starttime,
			"endtime":s_endtime
		});
	}

	function resetSearch() {
		$("#s_payer").val("");
		$("#s_tword").val("");
		$("#s_dataid").combobox("setValue", "");
		$("#s_starttime").datetimebox("setValue","");
		$("#s_endtime").datetimebox("setValue","");
	}
	
	function deletePay() {
		var selectedRows = $("#dg").datagrid('getSelections');
		if (selectedRows.length == 0) {
			$.messager.alert("系统提示", "请选择要删除的数据！");
			return;
		}
		var strIds = [];
		for (var i = 0; i < selectedRows.length; i++) {
			strIds.push(selectedRows[i].id);
		}
		var ids = strIds.join(",");
		$.messager.confirm("系统提示", "您确认要删除这<font color=red>"
				+ selectedRows.length + "</font>条数据吗？", function(r) {
			if (r) {
				$.post("${basePath}/paydelete.do", {
					ids : ids
				}, function(result) {
					if (result.errres) {
						$.messager.alert("系统提示", result.errmsg);
						$("#dg").datagrid("reload");
					} else {
						$.messager.alert("系统提示", "数据删除失败！");
					}
				}, "json");
			}
		});
	}

	function openPayAddDialog() {
		$("#dlg").dialog("open").dialog("setTitle", "添加支出信息");
		url = "${basePath}paysave.do";
	}

	function openPayModifyDialog() {
		var selectedRows = $("#dg").datagrid('getSelections');
		if (selectedRows.length != 1) {
			$.messager.alert("系统提示", "请选择一条要编辑的数据！");
			return;
		}
		var row = selectedRows[0];
		$("#dlg").dialog("open").dialog("setTitle", "编辑支出信息");
		$('#fm').form('load', row);
		url = "${basePath}paysave.do?id=" + row.id;
	}

	function savePay() {
		$("#fm").form("submit",{
			url : url,
			onSubmit : function() {
				if ($("#payer").combobox("getValue") == "" || $("#payer").combobox("getValue") == null) {
					$.messager.alert("系统提示", "请选择支出人！");
					return false;
				}
				if ($("#dataid").combobox("getValue") == "" || $("#dataid").combobox("getValue") == null) {
					$.messager.alert("系统提示", "请选择支出类型！");
					return false;
				}
				return $(this).form("validate");
			},
			success : function(result) {
				var result = eval('(' + result + ')');
				if (result.errres) {
					$.messager.alert("系统提示", result.errmsg);
					resetValue();
					$("#dlg").dialog("close");
					$("#dg").datagrid("reload");
				} else {
					$.messager.alert("系统提示", result.errmsg);
					return;
				}
			}
		});
	}
	
	function resetValue() {
		$("#payer").combobox("setValue", "");
		$("#money").numberbox("setValue", "");
		$("#content").val("");
		$("#paytime").datetimebox("setValue", "");
		$("#tword").val("");
		$("#dataid").combobox("setValue", "");
	}

	function closePayDialog() {
		$("#dlg").dialog("close");
		resetValue();
	}
	function openPayFindDialog(){
		var selectedRows=$("#dg").datagrid('getSelections');
		if(selectedRows.length!=1){
			$.messager.alert("系统提示","请选择一条要查看的数据！");
			return;
		}
		var row=selectedRows[0];
		$("#finddlg").dialog("open").dialog("setTitle","查看支出信息");
		$("#fusername").text(row.username);
		$("#fpayer").text(row.payer);
		$("#ftword").text(row.tword);
		$("#fmoney").text(row.money);
		$("#fdatadicvalue").text(row.datadicvalue);
		$("#fcontent").text(row.content);
		$("#fpaytime").text(row.paytime);
		$("#fcreatetime").text(row.createtime);
		$("#fupdatetime").text(row.updatetime);
	}
	
	function closeFindDialog(){
		$('#finddlg').dialog('close');
	}
</script>
<style>
	.findtable{
		border-width: 1px;
		border-color: #666666;
		border-collapse: collapse;
	}
	.findtable td{
		border-width: 1px;
		padding: 8px;
		border-style: solid;
		border-color: #666666;
		background-color: #ffffff;
	}
</style>
</head>
<body style="margin: 1px;">
	<table id="dg" title="支出管理" class="easyui-datagrid" fitColumns="true"
		pagination="true" rownumbers="true" url="${basePath}paylist.do?roleid=${currentUser.roleid}&userid=${currentUser.id}"
		fit="true" toolbar="#tb" remoteSort="false" multiSort="true">
		<thead>
			<tr>
				<th field="cb" checkbox="true" align="center"></th>
				<th field="id" width="50" align="center" sortable="true">编号</th>
				<!-- <th field="username" width="100" align="center" sortable="true">记录人</th> -->
				<th field="payer" width="100" align="center" sortable="true">支出人</th>
				<th field="tword" width="100" align="center" sortable="true">支出用途</th>
				<th field="money" width="100" align="center" sortable="true">金额</th>
				<th field="datadicvalue" width="100" align="center" sortable="true">支出类型</th>
				<th field="content" width="100" align="center" sortable="true">备注</th>
				<th field="paytime" width="100" align="center" sortable="true">支出时间</th>
				<!-- <th field="createtime" width="100" align="center" sortable="true">创建时间</th>
				<th field="updatetime" width="100" align="center" sortable="true">修改时间</th> -->
			</tr>
		</thead>
	</table>
	<div id="tb">
		<div>
			<a href="javascript:openPayAddDialog()" class="easyui-linkbutton" iconCls="icon-add" plain="true">添加</a> 
			<a href="javascript:openPayModifyDialog()" class="easyui-linkbutton" iconCls="icon-edit" plain="true">修改</a> 
			<a href="javascript:deletePay()" class="easyui-linkbutton"iconCls="icon-remove" plain="true">删除</a>
		    <a href="javascript:openPayFindDialog()" class="easyui-linkbutton" iconCls="icon-lsdd" plain="true">查看详细</a>
		</div>
		<div>
			&nbsp;支出人：&nbsp;<input type="text" id="s_payer" size="15" onkeydown="if(event.keyCode==13) searchPay()" />
			&nbsp;支出用途：&nbsp;<input type="text" id="s_tword" size="15" onkeydown="if(event.keyCode==13) searchPay()" />
			&nbsp;支出类型：&nbsp;<select class="easyui-combobox" id="s_dataid" editable="false" style="width: 100px;">
				<option value="">请选择...</option>
				<c:forEach items="${pays }" var="pay">
					<option value="${pay.id }">${pay.datadicvalue }</option>
				</c:forEach>
			</select>&nbsp;
			&nbsp;支出起止时间：&nbsp;<input type="text" id="s_starttime" class="easyui-datetimebox" size="18" onkeydown="if(event.keyCode==13) searchPay()"/>
			<span style="font-weight:bold;">&sim;</span>&nbsp;<input type="text" id="s_endtime" class="easyui-datetimebox" size="18" onkeydown="if(event.keyCode==13) searchPay()"/>
			<a href="javascript:searchPay()" class="easyui-linkbutton" iconCls="icon-search" plain="true">搜索</a> 
			<a href="javascript:resetSearch()" class="easyui-linkbutton" iconCls="icon-reset" plain="true">清空</a>
			
		</div>
	</div>

	<div id="dlg" class="easyui-dialog" style="width: 670px; height: 300px; padding: 10px 20px" closed="true" buttons="#dlg-buttons">
		<form id="fm" method="post">
			<table cellspacing="8px">
				<tr>
				    <td>支出人：</td>
					<td><select class="easyui-combobox" id="payer" name="payer" editable="true" style="width: 175px;">
							<option value="">请选择...</option>
							<c:forEach items="${allUsers }" var="alluser">
								<option value="${alluser.username }">${alluser.username }</option>
							</c:forEach>
						</select>&nbsp;<font color="red">*</font>
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>支出用途：</td>
					<td><input type="text" id="tword" name="tword" class="easyui-validatebox easyui-textbox" required="true" />&nbsp;<font color="red">*</font></td>
				</tr>
				<tr>
					<td>金额：</td>
					<td><input type="text" id="money" name="money" class="easyui-validatebox easyui-numberbox" required="true" />&nbsp;<font color="red">*</font></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>支出类型：</td>
					<td><select class="easyui-combobox" id="dataid" name="dataid" editable="false" style="width: 175px;">
							<option value="">请选择支出类型...</option>
							<c:forEach items="${pays }" var="pay">
								<option value="${pay.id }">${pay.datadicvalue }</option>
							</c:forEach>
					</select>&nbsp;<font color="red">*</font></td>		
				</tr>
				<tr><td>支出时间</td>
					<td><input id="paytime" name="paytime" class="easyui-datetimebox" required="true" style="width:140px">&nbsp;<font color="red">*</font></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td></td>
					<td><input type="hidden" id="userid" name="userid" class="easyui-validatebox easyui-textbox" required="true" value="${currentUser.id}"/></td>
				    
				</tr>
				<tr>
					<td>备注：</td>
					<td rowspan="3"><textarea id="content" name="content" style="height:60px" class="easyui-validatebox easyui-textbox" multiline="true"></textarea></td>
					<td></td>
					<td></td>
					<td></td>
				</tr>
			</table>
		</form>
	</div>
	<div id="dlg-buttons">
		<a href="javascript:savePay()" class="easyui-linkbutton" iconCls="icon-ok">保存</a> 
		<a href="javascript:closePayDialog()" class="easyui-linkbutton" iconCls="icon-cancel">关闭</a>
	</div>
	<div id="finddlg" class="easyui-dialog" style="width: 670px;height:300px;padding: 10px 20px" closed="true" buttons="#finddlg-buttons">
	 	<table cellspacing="8px" class="findtable" width="100%">
	 		<tr>
	 			<td>记录人：</td>
	 			<td><span id="fusername"></span></td>
	 			<td>支出人：</td>
	 			<td><span id="fpayer"></span></td>
	 		</tr>
	 		<tr>
	 			<td>支出用途：</td>
	 			<td><span id="ftword"></span></td>
	 			<td>金额：</td>
	 			<td><span id="fmoney"></span></td>
	 		</tr>
	 		<tr>
	 			<td>支出类型：</td>
	 			<td><span id="fdatadicvalue"></span></td>
	 			<td>备注：</td>
	 			<td><span id="fcontent"></span></td>
	 		</tr>
	 		<tr>
	 			<td>支出时间：</td>
	 			<td><span id="fpaytime"></span></td>
	 			<td>创建时间：</td>
	 			<td><span id="fcreatetime"></span></td>
	 		</tr>
	 		<tr>
	 			<td>修改时间：</td>
	 			<td><span id="fupdatetime"></span></td>
	 		</tr>
	 	</table>
	</div>
	<div id="finddlg-buttons">
		<a href="javascript:closeFindDialog()" class="easyui-linkbutton" iconCls="icon-ok">确定</a>
	</div>
</body>
</html>