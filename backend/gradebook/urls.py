from django.urls import path
from .views import TeacherGradeListView, StudentGradeListView, ParentGradeListView, GradeCreateView, GradeUpdateView


urlpatterns = [
    # Просмотр оценок
    path('teacher/', TeacherGradeListView.as_view(), name='teacher-grades'),
    path('student/', StudentGradeListView.as_view(), name='student-grades'),
    path('parent/', ParentGradeListView.as_view(), name='parent-grades'),

    # Создание и обновление оценок
    path('create/', GradeCreateView.as_view(), name='grade-create'),
    path('update/<int:pk>/', GradeUpdateView.as_view(), name='grade-update'),
]
