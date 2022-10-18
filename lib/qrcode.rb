module Qrcode
  def encode(id)
    "FW#{id.to_s.rjust(9, '0')}"
  end

  def decode(qr_code)
    qr_code.dup.slice(2..-1).to_i
  end
end
