# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class Api::V1::TodoListController < Api::ApiController
  def index
    begin
      page = params[:page] || 1
      per_page = params[:per_page] || 5
      @todo_list = TodoList.where(status: 'accepted')
      @todo_list = @todo_list.page(page).per(per_page)
      respond_without_location({result: @todo_list, total_count: @todo_list.total_count, page: @todo_list.current_page, last_page: @todo_list.last_page?})
    rescue => e
      Rails.logger.info( e.backtrace.join("\n"))
      respond_error "Can't load todo list"
    end
  end
  
  def create 
    begin
      todo_list = TodoList.new(todo_params)
      todo_list.save
      respond_without_location  todo_list, :created
    rescue => e
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      respond_error "Can't create todo list"
    end
  end
  
  def show
    begin
      todo_list = TodoList.find_by(id: params[:id])
      respond_without_location todo_list
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "todo list not exist"
    end
  end
  
  def update 
    begin
      todo_list = TodoList.find(params[:id])
      todo_list.update(todo_params)
      respond_without_location  TodoList.find(params[:id]), :created
    rescue => e
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      respond_error "Can't upload todo list"
    end
  end
  
  def destroy
    begin
      @trip = TodoList.find(params[:id])
      @trip.destroy
      respond_success("success")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Can't delete todo list"
    end
  end
  
  private
  def todo_params
    params.permit(:trip_id, :todo, :lat, :long, :is_delete, :status, :create_date)
  end
end
