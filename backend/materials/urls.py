from django.urls import path
from .views import MaterialListView, MaterialCreateView, MaterialUpdateView, MaterialDeleteView, download_material

urlpatterns = [
    path('materials/', MaterialListView.as_view(), name='material-list'),
    path('create-materials/', MaterialCreateView.as_view(), name='material-create'),
    path('update-materials/<int:pk>/', MaterialUpdateView.as_view(), name='material-update'),
    path('delete-materials/<int:pk>/', MaterialDeleteView.as_view(), name='material-delete'),

    path('download/<int:pk>/', download_material, name='download_material'),
]
