# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show]
  before_action :set_current_user_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = if Blog.find(params[:id]).secret == false
              Blog.find(params[:id])
            elsif user_signed_in?
              current_user.blogs.find(params[:id])
            else
              raise ActiveRecord::RecordNotFound
            end
  end

  def set_current_user_blog
    @blog = current_user.blogs.find(params[:id]) if current_user.blogs.find(params[:id]).present?
  end

  def blog_params
    permit_items = %i[title content secret]
    if current_user.premium?
      params.require(:blog).permit(permit_items, :random_eyecatch)
    else
      params.require(:blog).permit(permit_items)
    end
  end
end
