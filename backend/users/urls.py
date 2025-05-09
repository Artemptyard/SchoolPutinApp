from django.urls import path, include
from .views import UserCreator, UserManager, StudentCreater, StudentManager, KinshipManager, StudentList, \
    TeacherManager, ParentManager, get_parents, get_children, SubjectsManager

urlpatterns = [
    path("create_user/", UserCreator.as_view()),
    path("manage_user/<int:pk>/", UserManager.as_view()),

    path("create_student/", StudentCreater.as_view()),
    path("manage_student/<int:pk>", StudentManager.as_view()),
    path("get_students/", StudentList.as_view()),

    path("manage_parent/<int:pk>", ParentManager.as_view()),
    path("manage_teacher/<int:pk>", TeacherManager.as_view()),

    path("manage_kinship/<int:student_id>/<int:parent_id>", KinshipManager.as_view()),
    path("get_children/<int:parent_id>", get_children),
    path("get_parents/<int:student_id>", get_parents),

    path("manage_subjects/<int:teacher_id>/<int:subject_id>", SubjectsManager.as_view()),
]
