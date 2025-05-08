from django.urls import path
from .views import LearningMaterialListView, LearningMaterialCreateView, LearningMaterialUpdateView, LearningMaterialDeleteView

urlpatterns = [
    path('materials/', LearningMaterialListView.as_view(), name='material-list'),
    path('materials/create/', LearningMaterialCreateView.as_view(), name='material-create'),
    path('materials/<int:pk>/edit/', LearningMaterialUpdateView.as_view(), name='material-update'),
    path('materials/<int:pk>/delete/', LearningMaterialDeleteView.as_view(), name='material-delete'),
]
