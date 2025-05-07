from django.urls import path, include
from .views import UserCreator, UserManager, StudentCreater, StudentManager, KinshipManager, StudentList, \
    TeacherManager, ParentManager, get_parents, get_children

urlpatterns = [
    path("users/create_user/", UserCreator.as_view()),
    path("users/manage_user/<int:pk>/", UserManager.as_view()),

    path("users/create_student/", StudentCreater.as_view()),
    path("users/manage_student/<int:pk>", StudentManager.as_view()),
    path("users/get_students/", StudentList.as_view()),

    path("users/manage_parent/<int:pk>", ParentManager.as_view()),
    path("users/manage_teacher/<int:pk>", TeacherManager.as_view()),

    path("users/manage_kinship/<int:student_id>/<int:parent_id>", KinshipManager.as_view()),
    path("users/get_children/<int:parent_id>", get_children),
    path("users/get_parents/<int:student_id>", get_parents),
]
