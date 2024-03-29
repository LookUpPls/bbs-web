<%@ page import="com.ljj.dao.IReplyDao" %>
<%@ page import="com.ljj.entity.Post" %>
<%@ page import="com.ljj.entity.Reply" %>
<%@ page import="com.ljj.factory.MySqlSessionFactory" %>
<%@ page import="org.apache.ibatis.session.SqlSession" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
    <title>${postId}</title>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
    <script src="resouce/js/cookie.js"></script>
    <script src="resouce/js/jquery-3.1.1.js" type="application/javascript"></script>
    <script src="resouce/js/bootstrap.min.js"></script>
    <script src="resouce/js/vue.js"></script>
    <script src="resouce/js/element.js" type="application/javascript"></script>
    <link href="resouce/css/element-ui.css" rel="stylesheet"/>

    <link href="resouce/css/bootstrap.min.css" rel="stylesheet">

    <script src="resouce/js/validate-then-ajax-send.js"></script>
    <style>
        .body {
            width: 400px;
            margin: 200px auto;
            border: 1px solid gray;
            padding: 20px;
            border-radius: 5px;
        }

        .table-responsive {
            max-width: 1000px;
            margin: 20px auto;
        }

        table {
            background-color: rgba(255, 255, 255, 0.90);
        }

        table td {
            vertical-align: middle !important;
            width: min-content;
        }

        .icon-button-del {
            border: 1px black solid;
            border-radius: 2px;
            padding: 1px;
        }

        .icon-button-add {
            border: 1px black solid;
            border-radius: 2px;
        }
    </style>
</head>
<body>
</h1>
<div class="center-block">
        <%
        int postId = Integer.parseInt(request.getParameter("postId"));
        SqlSession sqlSession = MySqlSessionFactory.getSqlSession();

//        Post post = sqlSession.selectOne("getAll", postId);

        IReplyDao dao = sqlSession.getMapper(IReplyDao.class);
        Post post = dao.getAll(postId);

        List<Reply> replys = post.getReplies();
        pageContext.setAttribute("post", post);
        pageContext.setAttribute("replys", replys);
    %>
    <div id="app-table">
        <el-table
                :data="tableData"
                style="width: 100%"
                max-height="2250px">

            <el-table-column
                    sortable
                    prop="id"
                    label="#"
                    width="60">
            </el-table-column>
            <el-table-column
                    prop="content"
                    label="内容"
                    width="220">
            </el-table-column>
            <el-table-column
                    prop="time"
                    label="时间"
                    width="220">
            </el-table-column>
            <el-table-column
                    prop="userName"
                    label="发帖人"
                    width="80">
            </el-table-column>
            <el-table-column
                    fixed="right"
                    label="操作"
                    width="160">
                <div slot-scope="scope">
                    <el-button
                            type="warning"
                            size="small"
                            @click="handleEdit(scope.$index, scope.row)">编辑
                    </el-button>
                    <el-popover
                            placement="top"
                            width="160"
                            trigger="click">
                        <p>这是一段内容这是一段内容确定删除吗？</p>
                        <div style="text-align: right; margin: 0">
                            <el-button type="primary" size="mini"
                                       @click="deleteRow(scope.$index, tableData)">确定
                            </el-button>
                        </div>
                        <el-button type="danger" size="small" slot="reference">
                            移除
                        </el-button>
                    </el-popover>

                </div>
            </el-table-column>
        </el-table>
    </div>

    <script>
        var blockId = ${blockId};
        var postId = ${postId};

        var app_table = new Vue({
            el: "#app-table",
            methods: {
                deleteRow(index, rows) {
                    $.ajax({
                        url: "reply",
                        type: "post",
                        data: "id=" + rows[index].id + "&postId=" + postId + "&type=delete",
                        success: function (data) {
                            data = JSON.parse(data);
                            if (1 == data['code']) {
                                rows.splice(index, 1);
                            }
                            app_table.$message({message: data['message'], type: 'success'});
                        }
                    });
                }, handleEdit(index, row) {
                    app_dialog.dialogFormVisible = true;
                    app_dialog.title = "删除";
                    app_dialog.index = index;

                }, formatter(row, column) {
                    //console.log(row, column);
                    return row.address + "formatted";
                }
            },
            data() {
                return {
                    visible: false,
                    tableData: [
                        <c:forEach var="reply" items="${replys}">
                        {
                            id: '${reply.id}',
                            content: '${reply.context}',
                            time: '${reply.getFormatTime()}',
                            userName: '${reply.getUserName()}'
                        },
                        </c:forEach>
                    ]
                }
            }
        });
    </script>

    <div id="dialog">
        <el-button type="text" @click="dialogFormVisible = true;app_dialog.title='回复'">添加</el-button>

        <el-dialog title="dsaf" :visible.sync="dialogFormVisible" center>
            <el-form >
                <el-form-item label="内容" :label-width="formLabelWidth">
                    <el-input v-model="content" autocomplete="off"></el-input>
                </el-form-item>
            </el-form>
            <div slot="footer" class="dialog-footer">
                <el-button @click="dialogFormVisible = false">取 消</el-button>
                <el-button type="primary" @click="dialogFormVisible = false;submit()">确 定</el-button>
            </div>
        </el-dialog>
    </div>

    <script>
        var app_dialog = new Vue({
            el: "#dialog",
            data: {
                index: 0,
                title: "回复",
                dialogFormVisible: false,

                    content: '123123',

                formLabelWidth: '40px'
            }, methods: {
                submit:function (){
                    if (this.title === "回复")
                        $.ajax({//添加内容
                            url: "reply",
                            type: "post",
                            data: "content=" + content + "&blockId=" + "&type=add" + "&postId=" + postId + "&time=" + Date.parse(new Date()),
                            success: function (data) {
                                data = JSON.parse(data);
                                console.log(data);
                                if (data['code'] === 1) {
                                    app_dialog.$message({message: data['message'], type: 'success'});
                                    //window.location.reload();
                                    app_table.tableData.push({
                                        id: data['id'],
                                        content: app_dialog.content,
                                        time: Date.parse(new Date()),
                                        userName: 'temp'
                                    })
                                } else if (data['code'] === 0) {
                                    app_dialog.$message({message: data['message'], type: 'fail'});
                                }
                            }
                        });
                    else
                        $.ajax({ //修改内容
                            url: "reply",
                            type: "post",
                            data: "content=" + this.form.content + "&id=" + app_table.tableData[this.index].id + "&blockId=" + blockId + "&postId=" + postId + "&type=" + "change",
                            success: function (data) {
                                data = JSON.parse(data);
                                app_dialog.$message({message: data['message']});
                                if (data["code"] === 1) {
                                    app_table.tableData[app_dialog.index].content = app_dialog.form.content;
                                    this.dialogFormVisible = false;
                                }
                            }
                        });
                }
            }
        });
    </script>


    <!--一下为公用-->
    <!--信息提示模态框-->
    <div class="modal fade" id="mes" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-body">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                </div>
            </div>
        </div>
    </div>
    <script>
        function showMessage(message) {
            var mesText = $("#mes .modal-body");
            if (1 == $("#mes.in").length)
                mesText.append("<h1>" + message + "</h1>");
            else
                mesText.empty().append("<h1>" + message + "</h1>");

            //$("#mes").modal('keyboard');
            $("#mes").modal('show');
        }

        function progressMessage(data) {
            if (data['message'])
                showMessage(data['message']);
            if (data['address']) {
                setTimeout("showMessage('跳转中...')", 2000);
                //前面要加上'http://'才是绝对地址
                temp = document.domain + data['address'];
                setTimeout("window.location.href='http://" + temp + "'", 3000);
            }
        }

        function reDir(pathName) {
            if (document.location.pathname != pathName) {
                showMessage('跳转中...');
                //前面要加上'http://'才是绝对地址
                temp = document.domain + pathName;
                setTimeout("window.location.href='http://" + temp + "'", 1000);
            }
        }
    </script>
</body>
</html>