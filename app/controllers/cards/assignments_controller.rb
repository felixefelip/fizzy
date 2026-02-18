# rbs_inline: enabled

class Cards::AssignmentsController < ApplicationController
  include CardScoped

  def create
    if @card.toggle_assignment @board.users.active.find(params[:assignee_id])
      respond_to do |format|
        format.turbo_stream
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.json { head :unprocessable_entity }
      end
    end
  end
end
