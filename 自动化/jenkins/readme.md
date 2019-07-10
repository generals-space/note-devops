jenkins只是提供了流水线机制, 但具体的构建/部署逻辑还是要通过脚本装填进去.

比如jenkins不能实现并发, 所以一般脚本中通过调用ansible/saltstack批量操作.
